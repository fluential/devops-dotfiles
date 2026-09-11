#!/usr/bin/env bash
# Link Claude Code user config from this repo into ~/.claude. Safe to re-run:
# correct links are left alone, and a real file in the way is moved aside
# (never deleted) before linking. Runtime state in ~/.claude (projects, memory,
# history, sessions) stays local and out of the repo.
set -euo pipefail

CLAUDE_DOTFILES="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_HOME="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
mkdir -p "$CLAUDE_HOME"

for item in settings.json CLAUDE.md statusline.sh; do
  target="$CLAUDE_DOTFILES/$item"
  dest="$CLAUDE_HOME/$item"
  [ -e "$target" ] || { echo "missing in repo: $target" >&2; exit 1; }

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$target" ]; then
    echo "ok      $dest"
    continue
  fi

  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    backup="$dest.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
    mv "$dest" "$backup"
    echo "backup  $dest -> $backup"
  fi

  ln -sfn "$target" "$dest"
  echo "linked  $dest -> $target"
done
