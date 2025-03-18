#  Zap Plugin Manager
# Load Zap if installed
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# history
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=50000


# Plugin List
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/completions"
plug "zsh-users/zsh-history-substring-search"
plug "romkatv/powerlevel10k"

#  Completion System
# Load and initialize completion system
autoload -Uz compinit
compinit

#  Aliases
# File listing (using eza if available)
if [[ -x "$(which eza)" ]]; then
    alias ls='eza'
    alias l='eza -lh --icons=auto'
    alias ll='eza -lha --icons=auto --sort=name --group-directories-first'
    alias ld='eza -lhD --icons=auto'
    alias lt='eza --icons=auto --tree'
fi

# Package management
alias un='paru -Rns'
alias up='paru -Syu'
alias pl='paru -Qs'
alias pa='paru -Ss'
alias pc='paru -Sc'
alias po='paru -Qtdq | paru -Rns -'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# General utilities
alias c='clear'
alias vc='code'
alias fastfetch='fastfetch --logo-type kitty'
alias mkdir='mkdir -p'
alias ts='sudo -E timeshift-gtk'

# keybinds
bindkey '^ ' autosuggest-accept

export PATH="$HOME/.local/bin":$PATH

if command -v bat &> /dev/null; then
  alias cat="bat -pp --theme \"Visual Studio Dark+\"" 
  alias catt="bat --theme \"Visual Studio Dark+\"" 
fi

# Source additional configurations if they exist
[[ -f ~/.hyde.zshrc ]] && source ~/.hyde.zshrc
