#!/bin/bash
# Bootstraps local dev tooling for the t430-homelab repo.
# Safe to re-run — skips anything already installed.

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SHELLCHECK_VERSION="stable"
ARCH="x86_64"

mkdir -p "$INSTALL_DIR"

# ---- shellcheck -------------------------------------------------------------
if [[ -x "$INSTALL_DIR/shellcheck" ]]; then
  echo "shellcheck already installed: $("$INSTALL_DIR/shellcheck" --version | grep version:)"
else
  echo "Installing shellcheck..."
  TMP=$(mktemp -d)
  curl -sL "https://github.com/koalaman/shellcheck/releases/download/${SHELLCHECK_VERSION}/shellcheck-${SHELLCHECK_VERSION}.linux.${ARCH}.tar.xz" \
    | tar -xJ -C "$TMP"
  cp "$TMP/shellcheck-${SHELLCHECK_VERSION}/shellcheck" "$INSTALL_DIR/shellcheck"
  chmod +x "$INSTALL_DIR/shellcheck"
  rm -rf "$TMP"
  echo "shellcheck installed to $INSTALL_DIR/shellcheck"
fi

# ---- PATH -------------------------------------------------------------------
if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
  echo "Add the following to your shell profile to persist PATH:"
  echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
fi

# ---- GPG signing ------------------------------------------------------------
AGENT_CONF="$HOME/.gnupg/gpg-agent.conf"
mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"

if grep -q 'pinentry-program' "$AGENT_CONF" 2>/dev/null; then
  echo "gpg-agent.conf already configured"
else
  echo "Configuring gpg-agent for SSH/headless use..."
  cat >> "$AGENT_CONF" <<'EOF'
pinentry-program /usr/bin/pinentry-curses
default-cache-ttl 3600
max-cache-ttl 86400
EOF
  gpgconf --kill gpg-agent
  echo "gpg-agent configured"
fi

if ! grep -q 'GPG_TTY' "$HOME/.bashrc" 2>/dev/null; then
  # shellcheck disable=SC2016  # single quotes intentional: $(tty) must expand at login, not now
  echo 'export GPG_TTY=$(tty)' >> "$HOME/.bashrc"
  echo "GPG_TTY added to ~/.bashrc"
else
  echo "GPG_TTY already set in ~/.bashrc"
fi
