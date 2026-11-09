#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# INSTALL SETTINGS
# ==========================================

DOTFILES_DIR="$HOME/.dotfiles"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="$(id -un)"

# ==========================================
# HELPERS
# ==========================================

info() {
    printf '\n\033[1;34m==> %s\033[0m\n' "$*"
}

success() {
    printf '\033[1;32m[OK]\033[0m %s\n' "$*"
}

warn() {
    printf '\033[1;33m[WARN]\033[0m %s\n' "$*" >&2
}

die() {
    printf '\033[1;31m[ERROR]\033[0m %s\n' "$*" >&2
    exit 1
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

system_service_exists() {
    systemctl cat "$1" >/dev/null 2>&1
}

user_service_exists() {
    systemctl --user cat "$1" >/dev/null 2>&1
}

enable_system_service() {
    local unit="$1"

    if system_service_exists "$unit"; then
        info "Enabling system service: $unit"
        sudo systemctl enable --now "$unit"
    else
        warn "Service not found: $unit"
    fi
}

enable_user_service() {
    local unit="$1"

    if user_service_exists "$unit"; then
        info "Enabling user service: $unit"
        systemctl --user enable --now "$unit"
    else
        warn "User service not found: $unit"
    fi
}

# ==========================================
# 0. PRE-FLIGHT CHECK
# ==========================================

info "Checking installation environment..."

[[ "$EUID" -ne 0 ]] || die "Do not run this script as root."

command_exists sudo || die "sudo is required."

sudo -v

# ==========================================
# 1. PACKAGE MANAGER (PARU)
# ==========================================

info "Installing base development tools..."

sudo pacman -Syu --needed --noconfirm \
    base-devel \
    git \
    zram-generator \
    interception-caps2esc \
    xdg-user-dirs

if ! command_exists paru; then
    info "Installing paru from AUR..."

    BUILD_DIR="$(mktemp -d /tmp/paru-build.XXXXXX)"

    trap 'rm -rf -- "$BUILD_DIR"' EXIT

    git clone https://aur.archlinux.org/paru.git "$BUILD_DIR"

    (
        cd "$BUILD_DIR"
        makepkg -si --noconfirm
    )

    rm -rf -- "$BUILD_DIR"
    trap - EXIT
fi

command_exists paru || die "paru installation failed."

success "Package manager ready."

# ==========================================
# 2. BARE DOTFILES CHECKOUT
# ==========================================

info "Checking Bare Dotfiles repository..."

[[ -d "$DOTFILES_DIR" ]] || die \
    "Bare repository not found: $DOTFILES_DIR"

dotfiles() {
    /usr/bin/git \
        --git-dir="$DOTFILES_DIR" \
        --work-tree="$HOME" \
        "$@"
}

[[ "$(dotfiles rev-parse --is-bare-repository)" == "true" ]] \
    || die "$DOTFILES_DIR is not a bare repository."

dotfiles rev-parse --verify HEAD >/dev/null \
    || die "Bare repository has no valid HEAD commit."

dotfiles config --local status.showUntrackedFiles no

info "Checking out dotfiles..."

dotfiles checkout

success "Dotfiles checkout completed."

# ==========================================
# 3. INSTALL APPLICATION PACKAGES
# ==========================================

info "Installing application packages..."

PKGLIST=""

if [[ -f "$SCRIPT_DIR/pkglist.txt" ]]; then
    PKGLIST="$SCRIPT_DIR/pkglist.txt"
elif [[ -f "$HOME/pkglist.txt" ]]; then
    PKGLIST="$HOME/pkglist.txt"
fi

if [[ -n "$PKGLIST" ]]; then

    # Remove blank lines and comments.
    mapfile -t PACKAGES < <(
        sed 's/#.*//' "$PKGLIST" |
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
        grep -v '^$' || true
    )

    if (( ${#PACKAGES[@]} > 0 )); then
        paru -S --needed --noconfirm "${PACKAGES[@]}"
        success "Application packages installed."
    else
        warn "pkglist.txt is empty."
    fi
else
    warn "pkglist.txt not found."
fi

# ==========================================
# 4. YAZI PLUGIN
# ==========================================

info "Configuring Yazi plugin..."

if command_exists ya; then
    ya pkg add boydaihungst/mediainfo
    success "Yazi mediainfo plugin installed."
else
    warn "Yazi not installed. Skipping plugin."
fi

# ==========================================
# 5. SYSTEM SERVICES
# ==========================================

info "Enabling system services..."

enable_system_service NetworkManager.service
enable_system_service ly.service

# ==========================================
# 6. ZRAM CONFIGURATION
# ==========================================

info "Configuring ZRAM..."

sudo tee /etc/systemd/zram-generator.conf >/dev/null <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF

sudo systemctl daemon-reload

sudo systemctl start systemd-zram-setup@zram0.service

if command_exists zramctl; then
    zramctl
fi

success "ZRAM configured."


# ==========================================
# 7. CAPS2ESC CONFIGURATION
# ==========================================

configure_caps2esc() {
    info "Configuring CapsLock <-> Escape..."

    # Create udevmon configuration.
    sudo tee /etc/udevmon.yaml >/dev/null <<'EOF'
- JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF

    # Create udevmon systemd service.
    sudo tee /etc/systemd/system/udevmon.service >/dev/null <<'EOF'
[Unit]
Description=udevmon
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/udevmon.yaml

[Install]
WantedBy=multi-user.target
EOF

    # Reload systemd and enable udevmon.
    sudo systemctl daemon-reload
    sudo systemctl enable --now udevmon.service

    success "Caps2Esc configured."
}

configure_caps2esc


# ==========================================
# 8. FCITX5 LOTUS CONFIGURATION
# ==========================================

configure_fcitx5_lotus() {
    info "Configuring Fcitx5 Lotus..."

    # Reload udev rules for virtual input devices.
    info "Reloading udev rules..."

    sudo udevadm control --reload-rules
    sudo udevadm trigger

    # Load uinput kernel module.
    info "Loading uinput kernel module..."

    sudo modprobe uinput

    # Automatically load uinput on boot.
    echo "uinput" |
        sudo tee /etc/modules-load.d/uinput.conf >/dev/null

    # Enable Fcitx5 Lotus server.
    info "Starting Fcitx5 Lotus server..."

    local service="fcitx5-lotus-server@${CURRENT_USER}.service"

    sudo systemctl enable --now "$service" || {
        info "Running systemd-sysusers fallback..."

        sudo systemd-sysusers

        sudo systemctl enable --now "$service"
    }

    success "Fcitx5 Lotus server enabled."

    # Stop legacy IBus daemon.
    info "Cleaning up legacy IBus..."

    if command -v killall >/dev/null 2>&1; then
        killall ibus-daemon 2>/dev/null || {
            command -v ibus >/dev/null 2>&1 && ibus exit || true
        }
    elif command -v ibus >/dev/null 2>&1; then
        ibus exit || true
    fi

    success "Fcitx5 Lotus configured."
}

configure_fcitx5_lotus

# ==========================================
# 9. XDG USER DIRECTORIES
# ==========================================

info "Configuring XDG User Directories..."

xdg-user-dirs-update

# Redirect unused directories to HOME.
# No user files are deleted.

xdg-user-dirs-update --set MUSIC "$HOME"
xdg-user-dirs-update --set VIDEOS "$HOME"
xdg-user-dirs-update --set TEMPLATES "$HOME"
xdg-user-dirs-update --set PUBLICSHARE "$HOME"

success "XDG User Directories configured."

# ==========================================
# 10. USER SYSTEMD SERVICES
# ==========================================

info "Configuring user services..."

# Make scripts executable.
if [[ -d "$HOME/.local/bin" ]]; then

    find "$HOME/.local/bin" \
        -maxdepth 1 \
        -type f \
        -exec chmod +x {} +

fi

systemctl --user daemon-reload

enable_user_service bing-wallpaper.timer
enable_user_service bing-wallpaper-watcher.service

success "User services configured."

# ==========================================
# 11. ZSH ENVIRONMENT CONFIGURATION
# ==========================================

configure_zsh_environment() {
    info "Configuring Zsh environment..."

    local zshenv="/etc/zsh/zshenv"

    # Ensure /etc/zsh exists.
    sudo install -d -m 755 /etc/zsh

    # Create zshenv if it does not exist.
    if ! sudo test -f "$zshenv"; then
        sudo install -m 644 /dev/null "$zshenv"
    fi

    # Add XDG_CONFIG_HOME and ZDOTDIR configuration.
    if ! sudo grep -Fq 'export ZDOTDIR="$XDG_CONFIG_HOME/zsh"' "$zshenv"; then
        sudo tee -a "$zshenv" >/dev/null <<'EOF'

# Use XDG Base Directory for Zsh configuration.
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
EOF
        success "Zsh environment configuration added."
    else
        success "Zsh environment configuration already exists."
    fi
}

configure_zsh_environment

# ==========================================
# 12. DEFAULT USER SHELL
# ==========================================

info "Configuring default shell..."

if command_exists zsh; then

    TARGET_SHELL="$(command -v zsh)"
    CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"

    if [[ "$CURRENT_SHELL" == "$TARGET_SHELL" ]]; then
        success "Zsh is already the default shell."
    else

        if grep -Fxq "$TARGET_SHELL" /etc/shells; then
            sudo chsh -s "$TARGET_SHELL" "$CURRENT_USER"
            success "Default shell changed to Zsh."
        else
            warn "$TARGET_SHELL is not listed in /etc/shells."
        fi

    fi

else
    warn "Zsh is not installed."
fi

# ==========================================
# 13. FINISH
# ==========================================

echo
echo "=================================================="
echo " Installation completed!"
echo "=================================================="
echo
echo " Next steps:"
echo " 1. Check system services."
echo " 2. Check ZRAM with: zramctl"
echo " 3. Check swap with: swapon --show"
echo " 4. Log out and log back in."
echo
echo
echo "=================================================="
