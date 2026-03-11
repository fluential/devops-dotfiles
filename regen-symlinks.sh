#!/usr/bin/env bash

set -eou pipefail

cd $HOME
for file in .zpreztorc .zprezto .zsh_history .zshrc .vimrc .vim ;do
  ln -s $HOME/Documents/_DOCS/devops-dotfiles/$file
done
ln -s $HOME/Documents/_DOCS/.ssh
ln -s $HOME/Documents/_DOCS/.gnupg

