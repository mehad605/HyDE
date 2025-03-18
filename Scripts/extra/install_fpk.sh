#!/usr/bin/env bash
#|---/ /+-----------------------------------+---/ /|#
#|--/ /-| Script to install flatpaks (user) |--/ /-|#
#|-/ /--| Prasanth Rangan                   |-/ /--|#
#|/ /---+-----------------------------------+/ /---|#

baseDir=$(dirname "$(realpath "$0")")
scrDir=$(dirname "$(dirname "$(realpath "$0")")")

source "${scrDir}/global_fn.sh"
if [ $? -ne 0 ]; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

if ! pkg_installed flatpak; then
    sudo pacman -S flatpak
fi

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flats=$(awk -F '#' '{print $1}' "${baseDir}/custom_flat.lst" | sed 's/ //g' | xargs)

flatpak install --user -y flathub ${flats}
flatpak remove --unused

gtkTheme=$(gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g")
gtkIcon=$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")

flatpak --user override --filesystem=~/.themes
flatpak --user override --filesystem=~/.icons

flatpak --user override --filesystem=~/.local/share/themes
flatpak --user override --filesystem=~/.local/share/icons

flatpak --user override --env=GTK_THEME=${gtkTheme}
flatpak --user override --env=ICON_THEME=${gtkIcon}

# Modify Obsidian desktop file to add --ozone-platform=x11
DESKTOP_FILE="/home/maruf/.local/share/flatpak/exports/share/applications/md.obsidian.Obsidian.desktop"
if [ -f "$DESKTOP_FILE" ]; then
    # Create backup if it doesn't exist
    if [ ! -f "${DESKTOP_FILE}.backup" ]; then
        cp "$DESKTOP_FILE" "${DESKTOP_FILE}.backup"
    fi
    
    # Modify the file only if --ozone-platform=x11 is not already present
    if ! grep -q "md\.obsidian\.Obsidian.*--ozone-platform=x11" "$DESKTOP_FILE"; then
        sed -i '/^Exec=.*md\.obsidian\.Obsidian/ s/$/ --ozone-platform=x11/' "$DESKTOP_FILE"
        echo "Modified Obsidian desktop file to add --ozone-platform=x11"
    fi
else
    echo "Obsidian desktop file not found. Skipping modification."
fi
