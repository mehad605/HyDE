#!/usr/bin/env bash
#|---/ /+---------------------------+---/ /|#
#|--/ /-| Script to configure shell |--/ /-|#
#|-/ /--| Prasanth Rangan           |-/ /--|#
#|/ /---+---------------------------+/ /---|#

scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

# shellcheck disable=SC2154
if chk_list "myShell" "${shlList[@]}"; then
    print_log -sec "SHELL" -stat "detected" "${myShell}"
else
    print_log -sec "SHELL" -err "error" "no shell found..."
    exit 1
fi

# Install zap for zsh
if pkg_installed zsh; then
    if [[ ! -d "$HOME/.local/share/zap" ]]; then
        print_log -sec "SHELL" -stat "installing" "zap"
        if ! zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1; then
            print_log -err "zap installation failed..." "Please resolve this issue manually LATER ..."
        fi
    fi
fi

# set shell
if [[ "$(grep "/${USER}:" /etc/passwd | awk -F '/' '{print $NF}')" != "${myShell}" ]]; then
    print_log -sec "SHELL" -stat "change" "shell to ${myShell}..."
    chsh -s "$(which "${myShell}")"
else
    print_log -sec "SHELL" -stat "exist" "${myShell} is already set as shell..."
fi
