#!/usr/bin/env bash

set -eou pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

# Claude Code config. Runs first because the ln -s calls below are not
# re-runnable: they stop the script on a machine where the links already exist.
"$DOTFILES_DIR/claude/link.sh"

cd $HOME
for file in .zpreztorc .zprezto .zsh_history .zshrc .vimrc .vim ;do
  ln -s $HOME/Documents/_DOCS/devops-dotfiles/$file
done
ln -s $HOME/Documents/_DOCS/.ssh
ln -s $HOME/Documents/_DOCS/.gnupg
