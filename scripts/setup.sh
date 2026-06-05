#!/bin/bash
# Bootstraps local dev tooling for the t430-homelab repo.
# Safe to re-run — skips anything already installed.

set -euo pipefail

INSTALL_DIR="$HOME/.local/bin"
SHELLCHECK_VERSION="stable"
ARCH="x86_64"

mkdir -p "$INSTALL_DIR"

# ---- shellcheck -------------------------------------------------------------
if command -v shellcheck &>/dev/null; then
  echo "shellcheck already installed: $(shellcheck --version | grep version:)"
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
