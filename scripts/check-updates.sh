#!/usr/bin/env bash
#
# check-updates.sh — Homelab update & drift checker for the T430 node.
#
# Reports pending updates across three planes and notifies you ONLY when
# something is actually pending:
#   1. APT packages (incl. security updates) + pending reboot
#   2. Docker images (running containers vs. upstream registry digests)
#   3. Ollama release (pinned tag vs. latest GitHub release)
#   4. Git drift (local main vs. origin/main)
#
# Designed to run unattended as root via the accompanying systemd timer.
# Honors the homelab guardrails: it only CHECKS and REPORTS — it never
# pulls, upgrades, or restarts anything on its own.
#
# Notifications (optional): set in /etc/homelab-monitor.env
#   NTFY_URL="https://ntfy.sh/your-topic"   # ntfy push
#   WEBHOOK_URL="https://discord.com/..."   # Discord/Slack-style JSON webhook
#
set -uo pipefail

# ---- config -----------------------------------------------------------------
ENV_FILE="${HOMELAB_ENV_FILE:-/etc/homelab-monitor.env}"
# shellcheck source=/dev/null
[ -f "$ENV_FILE" ] && . "$ENV_FILE"

NTFY_URL="${NTFY_URL:-}"
WEBHOOK_URL="${WEBHOOK_URL:-}"
REPO_DIR="${REPO_DIR:-/home/imadear/t430-homelab}"
STATE_DIR="${STATE_DIR:-/var/lib/homelab-monitor}"
OLLAMA_PIN="${OLLAMA_PIN:-}"   # optional override of detected ollama tag
GITHUB_REPO="${GITHUB_REPO:-isaacmadearis/t430-homelab}"
GITHUB_TOKEN="${GITHUB_TOKEN:-}"   # optional PAT: lifts rate limits / private repos

mkdir -p "$STATE_DIR" 2>/dev/null || true
REPORT="$STATE_DIR/last-report.txt"

pending=0            # incremented for every actionable finding
lines=()
add()  { lines+=("$1"); }
flag() { pending=$((pending+1)); }

# ---- 1. APT -----------------------------------------------------------------
add "## APT packages"
if command -v apt-get >/dev/null 2>&1; then
  apt-get update -qq >/dev/null 2>&1 || add "  (apt update failed — run as root)"
  upg=$(apt list --upgradable 2>/dev/null | grep -v '^Listing' || true)
  if [ -n "$upg" ]; then
    n=$(printf '%s\n' "$upg" | grep -c . )
    sec=$(printf '%s\n' "$upg" | grep -ci security || true)
    add "  ⚠ $n upgradable ($sec security)"; flag
    while IFS= read -r l; do add "$l"; done <<< "$(printf '%s\n' "$upg" | sed 's/^/      /' | head -20)"
  else
    add "  ✓ up to date"
  fi
  if [ -f /var/run/reboot-required ]; then
    add "  ⚠ reboot required: $(cat /var/run/reboot-required.pkgs 2>/dev/null | tr '\n' ' ')"; flag
  fi
else
  add "  (apt not available)"
fi

# ---- 2. Docker images -------------------------------------------------------
add ""
add "## Docker images"
if command -v docker >/dev/null 2>&1; then
  while read -r name image; do
    [ -z "$name" ] && continue
    local_d=$(docker image inspect "$image" --format '{{index .RepoDigests 0}}' 2>/dev/null | sed 's/.*@//')
    remote_d=$(docker buildx imagetools inspect "$image" --format '{{json .Manifest.Digest}}' 2>/dev/null | tr -d '"')
    if [ -z "$remote_d" ]; then
      add "  ? $name ($image): registry unreachable"
    elif [ "$local_d" = "$remote_d" ]; then
      add "  ✓ $name ($image)"
    else
      add "  ⚠ $name ($image): newer image available for this tag"; flag
    fi
  done < <(docker ps --format '{{.Names}} {{.Image}}')
else
  add "  (docker not available)"
fi

# ---- 3. Ollama release ------------------------------------------------------
add ""
add "## Ollama release"
cur="$OLLAMA_PIN"
[ -z "$cur" ] && cur=$(docker ps --format '{{.Image}}' 2>/dev/null | grep -m1 'ollama/ollama:' | cut -d: -f2)
if [ -n "$cur" ]; then
  latest=$(curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest 2>/dev/null \
            | jq -r '.tag_name' 2>/dev/null | sed 's/^v//')
  if [ -z "$latest" ] || [ "$latest" = "null" ]; then
    add "  ? running $cur (GitHub API unreachable)"
  elif [ "$cur" = "$latest" ]; then
    add "  ✓ running $cur (latest)"
  else
    add "  ⚠ running $cur — latest is $latest"; flag
  fi
else
  add "  (no ollama container running)"
fi

# ---- 4. Git drift -----------------------------------------------------------
add ""
add "## Git (homelab repo)"
if [ -d "$REPO_DIR/.git" ]; then
  git -C "$REPO_DIR" fetch -q origin 2>/dev/null || true
  # shellcheck disable=SC1083  # @{u} is a git upstream refspec, not a shell brace expansion
  read -r ahead behind < <(git -C "$REPO_DIR" rev-list --left-right --count HEAD...@{u} 2>/dev/null | tr '\t' ' ' || echo "0 0")
  if [ "${behind:-0}" -gt 0 ]; then add "  ⚠ behind origin by $behind commit(s) — pull pending"; flag; fi
  if [ "${ahead:-0}" -gt 0 ]; then add "  ⚠ ahead of origin by $ahead commit(s) — push pending"; flag; fi
  [ "${ahead:-0}" -eq 0 ] && [ "${behind:-0}" -eq 0 ] && add "  ✓ in sync with origin/main"
else
  add "  (no git repo at $REPO_DIR)"
fi

# ---- 5. GitHub Actions failures --------------------------------------------
add ""
add "## GitHub Actions ($GITHUB_REPO)"
gh_auth=(); [ -n "$GITHUB_TOKEN" ] && gh_auth=(-H "Authorization: Bearer $GITHUB_TOKEN")
runs=$(curl -fsSL "${gh_auth[@]}" -H "Accept: application/vnd.github+json" \
        "https://api.github.com/repos/$GITHUB_REPO/actions/runs?per_page=20" 2>/dev/null)
if [ -z "$runs" ]; then
  add "  ? GitHub API unreachable"
elif [ "$(printf '%s' "$runs" | jq -r '.total_count' 2>/dev/null)" = "0" ]; then
  add "  ✓ no workflow runs yet"
else
  # Most recent run per workflow; flag any whose latest conclusion is failure
  # and that finished within the last 25h (matches the daily cadence).
  cutoff=$(date -u -d '25 hours ago' +%s 2>/dev/null || echo 0)
  fails=$(printf '%s' "$runs" | jq -r --argjson cut "$cutoff" '
    [.workflow_runs[] | select(.event != "dynamic")]
    | group_by(.workflow_id) | map(max_by(.run_number))
    | .[] | select(.conclusion == "failure")
    | select((.updated_at | fromdateiso8601) >= $cut)
    | "  ⚠ \(.name) #\(.run_number) failed on \(.head_branch) — \(.html_url)"' 2>/dev/null)
  if [ -n "$fails" ]; then
    while IFS= read -r l; do add "$l"; done <<< "$fails"; flag
  else
    add "  ✓ no recent failed runs"
  fi
fi

# ---- emit -------------------------------------------------------------------
header="Homelab update check — $(date '+%Y-%m-%d %H:%M %Z') — $pending item(s) pending"
{ echo "$header"; printf '%s\n' "${lines[@]}"; } | tee "$REPORT"

# ---- notify (only when something is pending) --------------------------------
if [ "$pending" -gt 0 ]; then
  body=$(printf '%s\n' "${lines[@]}")
  if [ -n "$NTFY_URL" ]; then
    curl -fsS -H "Title: $header" -H "Priority: default" -H "Tags: package" \
         -d "$body" "$NTFY_URL" >/dev/null 2>&1 || true
  fi
  if [ -n "$WEBHOOK_URL" ]; then
    payload=$(jq -Rn --arg t "$header"$'\n'"$body" '{content:$t, text:$t}')
    curl -fsS -H 'Content-Type: application/json' -d "$payload" "$WEBHOOK_URL" >/dev/null 2>&1 || true
  fi
fi

exit 0
