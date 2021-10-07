## DevOps Dotfiles

### Install

1. Install font `git clone https://github.com/powerline/fonts && cd fonts && bash install.sh`
2. `git clone --recursive https://github.com/fluential/devops-dotfiles`
3. `git submodule foreach --recursive git submodule update --init`
4. Symlink relevant files

#### 5. Install Plugins:

Launch vim and run `:PluginInstall`

To install from command line: `vim +PluginInstall +qall`


### Dependencies & Extras
* https://github.com/BurntSushi/ripgrep
* https://github.com/junegunn/fzf
* https://github.com/powerline/fonts (for vim status line)
