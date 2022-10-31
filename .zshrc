#
# .zshrc
#
# @author Chris van Meer
#

# Colors.
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

export ZSH=$HOME/.oh-my-zsh
ZSH_THEME="lukerandall"
ZSH_DISABLE_COMPFIX=true
DISABLE_AUTO_UPDATE=true

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Enable plugins.
plugins=(git brew ansible command-not-found history kubectl sudo web-search copyfile history-substring-search zsh-autosuggestions)

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

source $ZSH/oh-my-zsh.sh

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

if [ -f ~/.zsh_aliases ]
then
  source ~/.zsh_aliases
fi

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
kernel_name="$(uname -s)"
if [ "${kernel_name}" = "Linux" ]; then
  share_path="${ZSH_CUSTOM}/plugins"
elif [ "${arch_name}" = "x86_64" ]; then
  share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
  share_path="/opt/homebrew/share"
else
  echo "Unknown architecture: ${arch_name}"
fi

if [ "${kernel_name}" = "Darwin" ]; then
  export PATH="/usr/local/opt/curl/bin:$PATH"
fi

# Syntax highlighting
source ${HOME}/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

# No updates, we'll let Ansible handle this if neccesairy
zstyle ':omz:update' mode disabled

export HOMEBREW_AUTO_UPDATE_SECS=604800

# Delete a given line number in the known_hosts file.
rmknownh() {
  re='^[0-9]+$'
  if ! [[ $1 =~ $re ]] ; then
    echo "error: line number missing" >&2;
  else
    sed -i '' "$1d" ~/.ssh/known_hosts
  fi
}

# Stop a multipass instance, delete it and then purge the inventory
mpdelete() {
  if [[ -z $1 ]] ; then
    echo "Error: No container name specified" >&2;
  else
    multipass stop $1
    multipass delete $1
    multipass purge
  fi
}

mplaunch() {
  if [ $# -eq 1 ]; then
    multipass launch --name $1
    multipass info $1
  elif [ $# -eq 2 ]; then
    multipass launch --name $1 --cloud-init $2
    multipass info $1
  elif [ $# -eq 3 ]; then
    multipass launch --name $1 --cloud-init $2 $3
    multipass info $1
  elif [ $# -eq 4 ]; then
    n=0
    while [ $n -ne $4 ]
    do
      n=$(($n+1))
      nr=$(printf "%02d" $n)
      multipass launch --name $1$nr --cloud-init $2 $3
      multipass info $1$nr
    done
  elif [ $# -lt 1 ]; then
    echo "Usage: mplaunch <name> <cloud init file> <image> <count>"
  fi
}

unalias t >/dev/null 2>/dev/null
function t () {
  if [ "$(tmux list-windows | grep -c "$1")" -gt 0 ]; then
    windownumber=$(tmux list-windows | grep "$1" | cut -d ':' -f1)
    tmux select-window -t "$windownumber"
  else
    tmux new-window -n "$1" "ssh $1"
    tmux select-pane -T "$1"
  fi
}
