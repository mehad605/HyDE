#  Zap Plugin Manager
# Load Zap if installed
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"

# history
HISTFILE=~/.zsh_history


# History options
setopt appendhistory    # Append history to the file (don't overwrite it)
setopt incappendhistory # Add commands to history as soon as they are executed
setopt sharehistory     # Share history across multiple terminals
setopt histignoredups   # Ignore duplicate commands in history
setopt histignorespace  # Ignore commands that start with a space
HISTSIZE=1000
SAVEHIST=50000


# Plugin List
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/completions"
plug "zsh-users/zsh-history-substring-search"
plug "zap-zsh/supercharge"
plug "zap-zsh/fzf"
plug "zap-zsh/zap-prompt"

# keybinds
bindkey '^ ' autosuggest-accept


if command -v bat &> /dev/null; then
  alias cat="bat -pp --theme \"Visual Studio Dark+\"" 
  alias catt="bat --theme \"Visual Studio Dark+\"" 
fi

bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down





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
alias grubupdate='sudo grub-mkconfig -o /boot/grub/grub.cfg'


# keybinds
bindkey '^ ' autosuggest-accept

export PATH="$HOME/.local/bin":$PATH

if command -v bat &> /dev/null; then
  alias cat="bat -pp --theme \"Visual Studio Dark+\"" 
  alias catt="bat --theme \"Visual Studio Dark+\"" 
fi

# Source additional configurations if they exist
[[ -f ~/.hyde.zshrc ]] && source ~/.hyde.zshrc



