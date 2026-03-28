#!/usr/bin/env bash

set -eou pipefail

cd $HOME
for file in .zpreztorc .zprezto .zsh_history .zshrc .vimrc .vim ;do
  ln -s $HOME/Documents/_DOCS/devops-dotfiles/$file
done
ln -s $HOME/Documents/_DOCS/.ssh
ln -s $HOME/Documents/_DOCS/.gnupg

# Claude Code config
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$HOME/.claude"
for file in settings.json CLAUDE.md; do
  ln -sf "$DOTFILES_DIR/claude/$file" "$HOME/.claude/$file"
done
