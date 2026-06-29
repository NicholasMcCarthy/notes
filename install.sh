#!/usr/bin/env bash
set -euo pipefail

# Edit this after creating your GitHub repo, for example:
#   REPO="nickmccarthy/notes-cli"
REPO="${NOTES_CLI_REPO:-NicholasMcCarthy/notes}"
REF="${NOTES_CLI_REF:-latest-release}"
BINARY_NAME="${NOTES_CLI_BINARY_NAME:-notes}"
INSTALL_DIR="${NOTES_CLI_INSTALL_DIR:-}"
RAW_BASE="${NOTES_CLI_RAW_BASE:-https://raw.githubusercontent.com}"

usage() {
    cat <<'EOF'
Install notes-cli.

Usage:
  curl -Ls https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/notes-cli/latest-release/install.sh | bash
  curl -Ls https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/notes-cli/latest-release/install.sh | sudo bash

Optional environment variables:
  NOTES_CLI_REPO=owner/repo
  NOTES_CLI_REF=main
  NOTES_CLI_INSTALL_DIR=$HOME/.local/bin
EOF
}

if [ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ]; then
    usage
    exit 0
fi

if [ "$REPO" = "YOUR_GITHUB_USERNAME/notes-cli" ]; then
    cat >&2 <<'EOF'
error: installer repo is still set to YOUR_GITHUB_USERNAME/notes-cli.

Either edit install.sh before publishing, or run with:
  NOTES_CLI_REPO=owner/repo bash install.sh
EOF
    exit 1
fi

if [ -z "$INSTALL_DIR" ]; then
    if [ "$(id -u)" -eq 0 ]; then
        INSTALL_DIR="/usr/local/bin"
    else
        INSTALL_DIR="$HOME/.local/bin"
    fi
fi

SCRIPT_URL="$RAW_BASE/$REPO/$REF/bin/notes"
TMP_FILE="$(mktemp)"
cleanup() { rm -f "$TMP_FILE"; }
trap cleanup EXIT

if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$SCRIPT_URL" -o "$TMP_FILE"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$TMP_FILE" "$SCRIPT_URL"
else
    echo "error: curl or wget is required" >&2
    exit 1
fi

if ! grep -q 'APP_NAME="notes"' "$TMP_FILE"; then
    echo "error: downloaded file does not look like the notes script: $SCRIPT_URL" >&2
    exit 1
fi

mkdir -p "$INSTALL_DIR"
install -m 0755 "$TMP_FILE" "$INSTALL_DIR/$BINARY_NAME"

cat <<EOF
Installed $BINARY_NAME to $INSTALL_DIR/$BINARY_NAME

Try:
  $BINARY_NAME --version
  $BINARY_NAME --configure
EOF

case ":$PATH:" in
    *":$INSTALL_DIR:"*) ;;
    *)
        cat <<EOF

Note: $INSTALL_DIR is not currently on PATH.
Add this to your shell profile if needed:
  export PATH="$INSTALL_DIR:\$PATH"
EOF
        ;;
esac
