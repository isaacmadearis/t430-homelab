#!/usr/bin/env bash
#
# upgrade-ollama.sh — bump the CasaOS-managed Ollama container to a target tag.
#
# Run with sudo:  sudo TARGET=0.30.5 ./scripts/upgrade-ollama.sh
# Defaults to the latest GitHub release if TARGET is unset.
#
# Pulled models persist (they live in the named/host volume, not the image),
# so this is a safe in-place version bump. Backs up the compose first.
#
set -euo pipefail

APP_DIR="/var/lib/casaos/apps/big-bear-ollama-cpu"
COMPOSE="$APP_DIR/docker-compose.yml"

[ "$(id -u)" -eq 0 ] || { echo "Run as root (sudo)."; exit 1; }
[ -f "$COMPOSE" ] || { echo "Compose not found: $COMPOSE"; exit 1; }

TARGET="${TARGET:-}"
if [ -z "$TARGET" ]; then
  TARGET=$(curl -fsSL https://api.github.com/repos/ollama/ollama/releases/latest \
            | jq -r '.tag_name' | sed 's/^v//')
fi
echo "Target Ollama tag: $TARGET"

cur=$(grep -oE 'ollama/ollama:[^"[:space:]]+' "$COMPOSE" | head -1 | cut -d: -f2 || true)
echo "Current tag in compose: ${cur:-<none found>}"
[ "$cur" = "$TARGET" ] && { echo "Already at $TARGET — nothing to do."; exit 0; }

backup="$COMPOSE.bak.$(date +%Y%m%d-%H%M%S)"
cp -a "$COMPOSE" "$backup"
echo "Backed up compose -> $backup"

sed -i -E "s#(ollama/ollama:)[^\"[:space:]]+#\1${TARGET}#g" "$COMPOSE"
echo "Updated image tag -> ollama/ollama:$TARGET"

echo "Pulling new image (CPU-only, may take a while on the T430)..."
docker compose -f "$COMPOSE" pull ollama 2>/dev/null || docker compose -f "$COMPOSE" pull

echo "Recreating container..."
docker compose -f "$COMPOSE" up -d

echo "Done. Verify:"
docker ps --filter name=ollama --format '  {{.Names}} -> {{.Image}}  ({{.Status}})'
echo "Rollback if needed:  cp $backup $COMPOSE && docker compose -f $COMPOSE up -d"
