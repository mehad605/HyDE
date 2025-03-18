#!/usr/bin/env bash
#|---/ /+--------------------------------------+---/ /|#
#|--/ /-| Script to apply post install configs |--/ /-|#
#|-/ /--| Prasanth Rangan                      |-/ /--|#
#|/ /---+--------------------------------------+/ /---|#

scrDir=$(dirname "$(realpath "$0")")
# shellcheck disable=SC1091
if ! source "${scrDir}/global_fn.sh"; then
    echo "Error: unable to source global_fn.sh..."
    exit 1
fi

cloneDir="${cloneDir:-$CLONE_DIR}"

# sddm
if pkg_installed sddm; then
    print_log -c "[DISPLAYMANAGER] " -b "detected :: " "sddm"
    if [ ! -d /etc/sddm.conf.d ]; then
        sudo mkdir -p /etc/sddm.conf.d
    fi
    if [ ! -f /etc/sddm.conf.d/backup_the_hyde_project.conf ] || [ "${HYDE_INSTALL_SDDM}" = true ]; then
        print_log -g "[DISPLAYMANAGER] " -b " :: " "configuring sddm..."
        print_log -g "[DISPLAYMANAGER] " -b " :: " "Select sddm theme:" -r "\n[1]" -b " Candy" -r "\n[2]" -b " Corners"
        read -p " :: Enter option number : " -r sddmopt

        case $sddmopt in
        1) sddmtheme="Candy" ;;
        *) sddmtheme="Corners" ;;
        esac

        sudo tar -xzf "${cloneDir}/Source/arcs/Sddm_${sddmtheme}.tar.gz" -C /usr/share/sddm/themes/
        sudo touch /etc/sddm.conf.d/the_hyde_project.conf
        sudo cp /etc/sddm.conf.d/the_hyde_project.conf /etc/sddm.conf.d/backup_the_hyde_project.conf
        sudo cp /usr/share/sddm/themes/${sddmtheme}/the_hyde_project.conf /etc/sddm.conf.d/
    else
        print_log -y "[DISPLAYMANAGER] " -b " :: " "sddm is already configured..."
    fi

    if [ ! -f "/usr/share/sddm/faces/${USER}.face.icon" ] && [ -f "${cloneDir}/Source/misc/${USER}.face.icon" ]; then
        sudo cp "${cloneDir}/Source/misc/${USER}.face.icon" /usr/share/sddm/faces/
        print_log -g "[DISPLAYMANAGER] " -b " :: " "avatar set for ${USER}..."
    fi

else
    print_log -y "[DISPLAYMANAGER] " -b " :: " "sddm is not installed..."
fi

# dolphin
if pkg_installed dolphin && pkg_installed xdg-utils; then
    print_log -c "[FILEMANAGER] " -b "detected :: " "dolphin"
    xdg-mime default org.kde.dolphin.desktop inode/directory
    print_log -g "[FILEMANAGER] " -b " :: " "setting $(xdg-mime query default "inode/directory") as default file explorer..."

else
    print_log -y "[FILEMANAGER] " -b " :: " "dolphin is not installed..."
    printt_log -y "[FILEMANAGER] " -b " :: " "Setting $(xdg-mime query default "inode/directory") as default file explorer..."
fi

# shell
"${scrDir}/restore_shl.sh"

# flatpak
if ! pkg_installed flatpak; then
    print_log -r "[FLATPAK]" -b "list :: " "flatpak application"
    awk -F '#' '$1 != "" {print "["++count"]", $1}' "${scrDir}/extra/custom_flat.lst"
    prompt_timer 60 "Install these flatpaks? [Y/n]"
    fpkopt=${PROMPT_INPUT,,}

    if [ "${fpkopt}" = "y" ]; then
        print_log -g "[FLATPAK]" -b "install :: " "flatpaks"
        "${scrDir}/extra/install_fpk.sh"
    else
        print_log -y "[FLATPAK]" -b "skip :: " "flatpak installation"
    fi

else
    print_log -y "[FLATPAK]" -b " :: " "flatpak is already installed"
fi

# Configure GNOME Keyring PAM integration
if pkg_installed gnome-keyring; then
    print_log -g "[GNOME-KEYRING]" -b " :: " "Configuring PAM integration"
    
    # Configure login keyring unlock
    if [ -f /etc/pam.d/login ]; then
        sudo sed -i -e '/auth.*optional.*pam_gnome_keyring.so/d' \
                    -e '/session.*optional.*pam_gnome_keyring.so/d' \
                    -e '/auth.*include.*system-local-login/a auth       optional     pam_gnome_keyring.so' \
                    -e '/session.*include.*system-local-login/a session    optional     pam_gnome_keyring.so auto_start' \
                    /etc/pam.d/login
    fi

    # Configure for SDDM
    if [ -f /etc/pam.d/sddm ]; then
        sudo sed -i -e '/auth.*optional.*pam_gnome_keyring.so/d' \
                    -e '/session.*optional.*pam_gnome_keyring.so/d' \
                    -e '/auth.*include.*system-login/a auth       optional     pam_gnome_keyring.so' \
                    -e '/session.*include.*system-login/a session    optional     pam_gnome_keyring.so auto_start' \
                    /etc/pam.d/sddm
    fi
else
    print_log -y "[GNOME-KEYRING]" -b " :: " "Package not installed, skipping configuration"
fi

# Drive mounting
print_log -c "[DRIVE MOUNT] " -b "checking :: " "Man Cave drive"
MAN_CAVE_UUID="AC8ACDEC8ACDB2DE"
MAN_CAVE_DIR="${HOME}/Man_Cave"

# Create mount directory if it doesn't exist
if [ ! -d "$MAN_CAVE_DIR" ]; then
    if mkdir -p "$MAN_CAVE_DIR"; then
        print_log -g "[DRIVE MOUNT] " -b "created :: " "mount directory at ${MAN_CAVE_DIR}"
    else
        print_log -r "[DRIVE MOUNT] " -b "error :: " "failed to create mount directory"
    fi
fi

# Check if UUID exists
if blkid -U "${MAN_CAVE_UUID}" >/dev/null 2>&1; then
    # Define the fstab entry
    FSTAB_ENTRY="UUID=${MAN_CAVE_UUID} ${MAN_CAVE_DIR} ntfs defaults 0 0"

    # Check if entry already exists in fstab
    if ! grep -q "UUID=${MAN_CAVE_UUID}" /etc/fstab; then
        if echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab > /dev/null; then
            print_log -g "[DRIVE MOUNT] " -b "added :: " "entry to /etc/fstab"
            
            # Try to mount the drive
            if sudo mount "${MAN_CAVE_DIR}"; then
                print_log -g "[DRIVE MOUNT] " -b "success :: " "drive mounted at ${MAN_CAVE_DIR}"
            else
                print_log -r "[DRIVE MOUNT] " -b "error :: " "failed to mount drive"
            fi
        else
            print_log -r "[DRIVE MOUNT] " -b "error :: " "failed to modify /etc/fstab"
        fi
    else
        print_log -y "[DRIVE MOUNT] " -b "skipped :: " "fstab entry already exists"
    fi
else
    print_log -r "[DRIVE MOUNT] " -b "error :: " "drive with UUID ${MAN_CAVE_UUID} not found"
fi

