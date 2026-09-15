#
# Executes commands at the start of an interactive session.
#

# --- Prezto ---
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# --- PATH ---
export PATH="$HOME/bin:$HOME/.local/bin:$HOME/.local/bin/claude:$PATH"
export PATH="${PATH}:${HOME}/.krew/bin"

# --- Tool init ---
export LSCOLORS="ExGxBxDxCxEgEdxbxgxcxd"

export PYENV_ROOT="$HOME/.pyenv"
command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"
## Cached pyenv init — regenerate: pyenv init - > ~/.pyenv/init-cache.zsh
#if [[ -s "$PYENV_ROOT/init-cache.zsh" ]]; then
#  source "$PYENV_ROOT/init-cache.zsh"
#else
#  eval "$(pyenv init -)"
#fi

eval "$(fnm env --use-on-cd --shell zsh)"

source "/opt/homebrew/share/google-cloud-sdk/path.zsh.inc" || true
source "/opt/homebrew/share/google-cloud-sdk/completion.zsh.inc" || true
export CLOUDSDK_PYTHON_SITEPACKAGES=1
export CLOUDSDK_PYTHON=/opt/homebrew/opt/python3/bin/python3

export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/vault vault

# --- History (Atuin primary, zsh native as fallback) ---
#export HISTFILE="$HOME/.zsh_history"
#export HISTSIZE=50000
#export SAVEHIST=50000
setopt EXTENDED_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt HIST_VERIFY

export ATUIN_NOBIND="true"
eval "$(atuin init zsh)"

# Redefine the custom wrapper using 'zle' to properly call Atuin
_atuin_search_no_execute() {
  # Call the internal Atuin search widget through the Zsh Line Editor
  zle _atuin_search_widget

  # Refresh the command line display neatly when Atuin closes
  zle redisplay
}

# Register your wrapper function as a valid Zsh widget
zle -N _atuin_search_no_execute

# Bind Ctrl+R to your custom wrapper
bindkey '^R' _atuin_search_no_execute

# --- SSH ---
ssh-add -l &>/dev/null || ssh-add --apple-load-keychain 2>/dev/null

# --- Aliases ---
alias k=kubectl
alias vcat=/bin/cat
alias cat=/opt/homebrew/bin/bat
alias vlc='open -a vlc'
#alias ffmpeg='docker run -i --rm -u $UID:$GROUPS -v "$PWD:$PWD" -w "$PWD" mwader/static-ffmpeg:5.1.2'
alias pull_all="find . -type d -name .git -print -exec git --git-dir={} --work-tree=$PWD/{}/.. pull \;"
alias jlp-env='git config --local user.name "Michael Czerwinski";git config --local user.email "michael.czerwinski@johnlewis.co.uk";export GIT_SSH_COMMAND="ssh -i /Users/mcz/.ssh/id_rsa.jlp -o IdentitiesOnly=yes"'
alias mcz-env='git config --global user.name fluential;git config --global user.email fluential@users.noreply.github.com'

#source /Users/mcz/dev/JLP/gittmr/gitt-alias.sh

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[cursor]=underline

# --- Git log with fzf ---
gli() {
  local filter
  if [ -n $@ ] && [ -f $@ ]; then
    filter="-- $@"
  fi

  git log \
    --graph --color=always --abbrev=7 --format='%C(auto)%h %an %C(blue)%s %C(yellow)%cr' $@ | \
    fzf \
      --ansi --no-sort --reverse --tiebreak=index \
      --preview "f() { set -- \$(echo -- \$@ | grep -o '[a-f0-9]\{7\}'); [ \$# -eq 0 ] || git show --color=always \$1 $filter; }; f {}" \
      --bind "j:down,k:up,alt-j:preview-down,alt-k:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up,q:abort,ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | less -R') << 'FZF-EOF'
                {}
                FZF-EOF" \
      --preview-window=right:60% \
      --height 80%
}

alias glNoGraph='git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr% C(auto)%an" "$@"'
_gitLogLineToHash="echo {} | grep -o '[a-f0-9]\{7\}' | head -1"
_viewGitLogLine="$_gitLogLineToHash | xargs -I % sh -c 'git show --color=always % | diff-so-fancy'"
_viewGitLogLineUnfancy="$_gitLogLineToHash | xargs -I % sh -c 'git show %'"

gly() {
    glNoGraph |
        fzf --no-sort --reverse --tiebreak=index --no-multi \
            --ansi --preview="$_viewGitLogLine" \
                --header "enter to view, alt-y to copy hash, alt-v to open in vim" \
                --bind "enter:execute:$_viewGitLogLine   | less -R" \
                --bind "alt-v:execute:$_viewGitLogLineUnfancy | vim -" \
                --bind "alt-y:execute:$_gitLogLineToHash | xclip"
}

# --- GPG ---
export GPG_TTY=$(tty)

# SOPS age key for encrypted secrets
export SOPS_AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
export PATH="/opt/homebrew/opt/ffmpeg-full/bin:$PATH"
