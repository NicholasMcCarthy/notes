#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

export NOTES_CONFIG_FILE="$TMPDIR/config"
export NOTES_FILE="$TMPDIR/notes.tsv"
export EDITOR=true

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/notes"

"$SCRIPT" add -n work -t cli "first note"
"$SCRIPT" add -t personal "second note"
"$SCRIPT" add -n project -t cli,dev "third note"
"$SCRIPT" search first | grep "first note" > /dev/null
"$SCRIPT" list -l 3 | grep "second note" > /dev/null
"$SCRIPT" show 1 | grep "first note" > /dev/null

# Hostname is recorded and shown
"$SCRIPT" show 1 | grep "^Host:" > /dev/null

# Tag filtering
"$SCRIPT" list -t cli | grep "first note" > /dev/null
"$SCRIPT" list -t cli | grep "third note" > /dev/null
"$SCRIPT" list -t personal | grep "second note" > /dev/null
"$SCRIPT" search note -t cli | grep "first note" > /dev/null

# Host filtering
CURRENT_HOST="$(hostname 2>/dev/null || printf 'unknown')"
"$SCRIPT" list -H "$CURRENT_HOST" | grep "first note" > /dev/null
"$SCRIPT" search note -H "$CURRENT_HOST" | grep "first note" > /dev/null

# Update name and tags
"$SCRIPT" update 1 -n renamed | grep "Updated" > /dev/null
"$SCRIPT" show 1 | grep "renamed" > /dev/null
"$SCRIPT" update 1 -t newtag | grep "Updated" > /dev/null
"$SCRIPT" show 1 | grep "newtag" > /dev/null

# Delete with --force
"$SCRIPT" delete -f 1 | grep "Deleted" > /dev/null
"$SCRIPT" config | grep "^Notes:.*2$" > /dev/null

# Delete without --force (non-tty stdin skips prompt)
"$SCRIPT" delete 1 | grep "Deleted" > /dev/null
"$SCRIPT" config | grep "^Notes:.*1$" > /dev/null

# Auto-sync to directory on write
cat > "$NOTES_CONFIG_FILE" <<EOF
NOTES_DATETIME_FORMAT='%Y-%m-%d %H:%M:%S'
NOTES_DEFAULT_LIMIT=15
NOTES_FILE='$TMPDIR/notes.tsv'
NOTES_SYNC_DIR='$TMPDIR/sync'
EOF

"$SCRIPT" add "synced note"
test -f "$TMPDIR/sync/notes.tsv"
grep "synced note" "$TMPDIR/sync/notes.tsv" > /dev/null

printf 'Smoke tests passed.\n'
