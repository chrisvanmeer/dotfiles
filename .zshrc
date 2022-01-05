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
ZSH_THEME="tjkirch_mod"

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Enable plugins.
plugins=(git brew ansible command-not-found history kubectl sudo web-search copydir copyfile history-substring-search zsh-autosuggestions)

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
elif [ "${kernel_name}" = "Darwin" ]; then
    export PATH="/usr/local/opt/curl/bin:$PATH"
fi

if [ "${arch_name}" = "x86_64" ]; then
    share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
    share_path="/opt/homebrew/share"
else
    echo "Unknown architecture: ${arch_name}"
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
  re='^[0-9]+$'
  if [[ -z $1 ]] ; then
    echo "Error: No container name specified" >&2;
  else
    multipass stop $1
    multipass delete $1
    multipass purge
  fi
}
