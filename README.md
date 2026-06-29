# notes-cli

A tiny Bash CLI note taker.

It keeps the spirit of a one-file notes script, but adds stable IDs, safer deletion, tags, search, edit, config, local sync, optional `age` encryption, migration from an old `~/.notes` file, and a basic GitHub CI setup.

## Install from GitHub

After creating the repo, edit `install.sh` and replace:

```bash
REPO="${NOTES_CLI_REPO:-YOUR_GITHUB_USERNAME/notes-cli}"
```

with your real repo, for example:

```bash
REPO="${NOTES_CLI_REPO:-nickmccarthy/notes-cli}"
```

Then create a branch called `latest-release`:

```bash
git checkout -b latest-release
git push -u origin latest-release
```

Install with:

```bash
curl -Ls https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/notes-cli/latest-release/install.sh | bash
```

System-wide install:

```bash
curl -Ls https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/notes-cli/latest-release/install.sh | sudo bash
```

You can also install from `main`:

```bash
curl -Ls https://raw.githubusercontent.com/YOUR_GITHUB_USERNAME/notes-cli/main/install.sh | NOTES_CLI_REF=main bash
```

## Configure

Run:

```bash
notes --configure
```

This writes:

```bash
~/.config/notes-cli/config
```

It lets you set:

- date/time format
- default list/search limit
- notes database location
- sync directory, such as a local Google Drive, OneDrive, Dropbox, or Nextcloud folder
- sync mode: `none`, `plain`, or `age`
- optional `age` encryption key details

View current config:

```bash
notes config
```

## Usage

```bash
notes add -n work -t "idea,cli" "Make the notes CLI easier to use"
notes add "Quick untitled note"

notes
notes list -l 30
notes list --content
notes search cli
notes search -l 5 "github"

notes show 1
notes edit 1
notes delete 1

notes stats
notes path
```

You can also pipe content into it:

```bash
printf "This is a longer note\nwith multiple lines\n" | notes add -n scratch
```

## Sync

Configure first:

```bash
notes --configure
```

Then push to the configured sync directory:

```bash
notes sync push
```

Pull from the configured sync directory:

```bash
notes sync pull
```

Check sync config/status:

```bash
notes sync status
```

### Plain sync

`plain` mode copies this file to your sync directory:

```bash
notes.tsv
```

This is simple, but not private if your cloud folder is compromised.

### Encrypted sync with age

`age` mode encrypts your notes before copying:

```bash
notes.tsv.age
```

Install `age`, then run:

```bash
notes --configure
```

If `age-keygen` is available, the configure menu can generate a key for you.

## Storage

By default, notes are stored at:

```bash
~/.local/share/notes-cli/notes.tsv
```

Each row is a TSV record:

```text
id    timestamp    name    tags    content
```

## Migrating from the old script

Your old script stored notes in `~/.notes`. To import them:

```bash
notes migrate ~/.notes
```

The old file is not modified.

## Legacy shortcuts

These still work:

```bash
notes "quick note"
notes --name work "note content"
notes --recent 20
notes --search "some term"
notes --delete 3
notes --content 10
```

## Development

Run the smoke test:

```bash
bash tests/smoke.sh
```

Run ShellCheck if installed:

```bash
shellcheck bin/notes tests/smoke.sh install.sh
```
