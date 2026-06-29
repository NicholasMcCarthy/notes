#!/usr/bin/env bash
set -euo pipefail

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

export NOTES_CONFIG_FILE="$TMPDIR/config"
export NOTES_FILE="$TMPDIR/notes.tsv"
export EDITOR=true

SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/bin/notes"

"$SCRIPT" add -n work -t cli "first note"
"$SCRIPT" add "second note"
"$SCRIPT" search first | grep -q "first note"
"$SCRIPT" list -l 2 | grep -q "second note"
"$SCRIPT" show 1 | grep -q "first note"
"$SCRIPT" delete 1 | grep -q "Deleted"
"$SCRIPT" stats | grep -q "Notes:       1"

cat > "$NOTES_CONFIG_FILE" <<EOF
NOTES_DATETIME_FORMAT='%Y-%m-%d %H:%M:%S'
NOTES_DEFAULT_LIMIT=15
NOTES_FILE='$TMPDIR/notes.tsv'
NOTES_SYNC_DIR='$TMPDIR/sync'
NOTES_SYNC_MODE=plain
NOTES_AGE_RECIPIENT=''
NOTES_AGE_IDENTITY='$TMPDIR/age-key.txt'
EOF

"$SCRIPT" sync push | grep -q "Copied plaintext notes"
test -f "$TMPDIR/sync/notes.tsv"

printf 'Smoke tests passed.\n'
