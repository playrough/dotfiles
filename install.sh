#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# INSTALL SETTINGS
# ==========================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CURRENT_USER="$(id -un)"

LOG_DIR="$HOME/.local/state/dotfiles-installer"
LOG_FILE="$LOG_DIR/install.log"

BUILD_DIR=""

# ==========================================
# LOGGING
# ==========================================

install -d -m 700 "$LOG_DIR"

exec > >(tee -a "$LOG_FILE") 2>&1

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

cleanup() {
    if [[ -n "$BUILD_DIR" && -d "$BUILD_DIR" ]]; then
        rm -rf -- "$BUILD_DIR"
    fi
}

on_error() {
    local status=$1
    local line=$2
    local command=$3

    printf '\n\033[1;31m[ERROR]\033[0m Installation failed.\n' >&2
    printf 'Line: %s\nCommand: %s\n' "$line" "$command" >&2
    printf 'Log: %s\n' "$LOG_FILE" >&2

    exit "$status"
}

trap cleanup EXIT
trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR

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

# Write a managed system configuration.
# Backup the previous file only when its content changes.

write_managed_file() {
    local destination="$1"
    local mode="$2"
    local temp_file
    local backup_file

    temp_file="$(mktemp)"

    cat > "$temp_file"

    if sudo test -f "$destination" &&
       sudo cmp -s "$temp_file" "$destination"; then

        success "Configuration unchanged: $destination"
        rm -f "$temp_file"
        return 0
    fi

    if sudo test -e "$destination" ||
       sudo test -L "$destination"; then

        backup_file="${destination}.bak.$(date +%Y%m%d-%H%M%S)"

        sudo cp -a -- "$destination" "$backup_file"

        info "Backup created: $backup_file"
    fi

    sudo install -D -m "$mode" "$temp_file" "$destination"

    rm -f "$temp_file"

    success "Configuration written: $destination"
}

# ==========================================
# 0. PRE-FLIGHT CHECK
# ==========================================

info "Checking installation environment..."

[[ "$EUID" -ne 0 ]] ||
    die "Do not run this script as root."

[[ -f /etc/arch-release ]] ||
    die "This installer requires Arch Linux."

[[ "$(uname -m)" == "x86_64" ]] ||
    die "Unsupported architecture."

for cmd in sudo pacman git systemctl tee install; do
    command_exists "$cmd" ||
        die "Required command not found: $cmd"
done

sudo -v

success "Environment checks passed."

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

    git clone https://aur.archlinux.org/paru.git "$BUILD_DIR"

    (
        cd "$BUILD_DIR"
        makepkg -si --noconfirm
    )

fi

command_exists paru ||
    die "paru installation failed."

success "Package manager ready."

# ==========================================
# 2. BARE DOTFILES CHECKOUT
# ==========================================

info "Checking Bare Dotfiles repository..."

[[ -d "$DOTFILES_DIR" ]] ||
    die "Bare repository not found: $DOTFILES_DIR"

dotfiles() {
    /usr/bin/git \
        --git-dir="$DOTFILES_DIR" \
        --work-tree="$HOME" \
        "$@"
}

[[ "$(git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository)" == "true" ]] ||
    die "$DOTFILES_DIR is not a bare repository."

dotfiles rev-parse --verify HEAD >/dev/null ||
    die "Bare repository has no valid HEAD commit."

dotfiles config --local status.showUntrackedFiles no

info "Checking out dotfiles..."

if ! dotfiles checkout; then
    die "Dotfiles checkout failed.

Existing files may conflict with the repository.
Resolve conflicts manually, then run the installer again."
fi

success "Dotfiles checkout completed."


CONFIG_FILE="$HOME/.config/noctalia/noctalia-config.toml"

if [ -f "$CONFIG_FILE" ]; then
    sed -i "s|/home/[^/]*|$HOME|g" "$CONFIG_FILE"
fi

# ==========================================
# 3. APPLICATION PACKAGES
# ==========================================

info "Installing application packages..."

PKGLIST=""

if [[ -f "$SCRIPT_DIR/pkglist.txt" ]]; then
    PKGLIST="$SCRIPT_DIR/pkglist.txt"
elif [[ -f "$HOME/pkglist.txt" ]]; then
    PKGLIST="$HOME/pkglist.txt"
fi

if [[ -n "$PKGLIST" ]]; then

    mapfile -t PACKAGES < <(
        sed 's/#.*//' "$PKGLIST" |
        sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
        grep -v '^$' || true
    )

    if (( ${#PACKAGES[@]} > 0 )); then

        paru -Syu --needed --noconfirm "${PACKAGES[@]}"

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

write_managed_file \
    /etc/systemd/zram-generator.conf \
    644 <<'EOF'
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
EOF

sudo systemctl daemon-reload
sudo systemctl start systemd-zram-setup@zram0.service


# ==========================================
# 7. CAPS2ESC CONFIGURATION
# ==========================================

configure_caps2esc() {
    info "Configuring CapsLock <-> Escape..."

    for cmd in udevmon intercept caps2esc uinput; do
        command_exists "$cmd" ||
            die "Caps2Esc dependency not found: $cmd"
    done

    # udevmon configuration.

    write_managed_file /etc/udevmon.yaml 644 <<'EOF'
- JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF

    # udevmon systemd service.

    write_managed_file \
        /etc/systemd/system/udevmon.service \
        644 <<'EOF'
[Unit]
Description=udevmon
Wants=systemd-udev-settle.service
After=systemd-udev-settle.service

[Service]
ExecStart=/usr/bin/nice -n -20 /usr/bin/udevmon -c /etc/udevmon.yaml

[Install]
WantedBy=multi-user.target
EOF

    sudo udevadm control --reload-rules

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

    local service="fcitx5-lotus-server@${CURRENT_USER}.service"

    if ! system_service_exists "$service"; then
        warn "Fcitx5 Lotus service not found. Skipping."
        return 0
    fi

    # Reload udev rules.

    sudo udevadm control --reload-rules
    sudo udevadm trigger

    # Load uinput kernel module.

    sudo modprobe uinput

    # Automatically load uinput on boot.

    write_managed_file /etc/modules-load.d/uinput.conf 644 <<'EOF'
uinput
EOF

    sudo systemctl enable --now "$service" || {
        info "Running systemd-sysusers fallback..."
        sudo systemd-sysusers
        sudo systemctl enable --now "$service"
    }

    success "Fcitx5 Lotus server enabled."

    # Stop legacy IBus daemon.

    info "Cleaning up legacy IBus..."

    if command_exists killall; then
        killall ibus-daemon 2>/dev/null || true
    fi

    if command_exists ibus; then
        ibus exit 2>/dev/null || true
    fi

    success "Fcitx5 Lotus configured."
}

configure_fcitx5_lotus

# ==========================================
# 9. XDG USER DIRECTORIES
# ==========================================

info "Configuring XDG User Directories..."

if command_exists xdg-user-dirs-update; then
    xdg-user-dirs-update
else
    warn "xdg-user-dirs-update not found."
fi

success "XDG User Directories configured."

# ==========================================
# 10. USER SYSTEMD SERVICES
# ==========================================

info "Configuring user services..."

mkdir -p "$HOME/Downloads/wallpapers/bing"
mkdir -p "$HOME/Downloads/wallpapers/wallhaven"

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

    local begin_marker="# BEGIN DOTFILES ZSH CONFIG"
    local end_marker="# END DOTFILES ZSH CONFIG"

    # Ensure /etc/zsh exists.

    sudo install -d -m 755 /etc/zsh

    # Create zshenv if it does not exist.

    if ! sudo test -e "$zshenv" &&
       ! sudo test -L "$zshenv"; then

        sudo install -m 644 /dev/null "$zshenv"
    fi

    # Check configuration markers.

    if sudo grep -Fq "$begin_marker" "$zshenv"; then

        sudo grep -Fq "$end_marker" "$zshenv" ||
            die "Zsh configuration has an incomplete marker block."

        success "Zsh environment configuration already exists."

    elif sudo grep -Fq "$end_marker" "$zshenv"; then

        die "Zsh END marker exists without BEGIN marker."

    else

        sudo tee -a "$zshenv" >/dev/null <<'EOF'

# BEGIN DOTFILES ZSH CONFIG
if [[ -z "$XDG_CONFIG_HOME" ]]; then
    export XDG_CONFIG_HOME="$HOME/.config"
fi

if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
    export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
fi
# END DOTFILES ZSH CONFIG
EOF

        success "Zsh environment configuration added."
    fi

    # Create Zsh state and cache directories.

    install -d -m 700 \
        "$HOME/.local/state/zsh" \
        "$HOME/.cache/zsh"

    success "Zsh state and cache directories created."
}

configure_zsh_environment

# ==========================================
# 12. DEFAULT USER SHELL
# ==========================================

info "Configuring default shell..."

if command_exists zsh; then

    ZSH_PATH="$(command -v zsh)"
    ZSH_REAL="$(readlink -f "$ZSH_PATH")"

    CURRENT_SHELL="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"
    CURRENT_SHELL_REAL="$(readlink -f "$CURRENT_SHELL")"

    TARGET_SHELL=""

    # Find the canonical shell entry in /etc/shells.

    while IFS= read -r shell; do

        [[ "$shell" == /* && -x "$shell" ]] || continue

        if [[ "$(readlink -f "$shell")" == "$ZSH_REAL" ]]; then
            TARGET_SHELL="$shell"
            break
        fi

    done < /etc/shells

    if [[ -z "$TARGET_SHELL" ]]; then

        warn "$ZSH_PATH is not listed in /etc/shells."

    elif [[ "$CURRENT_SHELL_REAL" == "$ZSH_REAL" ]]; then

        success "Zsh is already the default shell."

    else

        sudo chsh -s "$TARGET_SHELL" "$CURRENT_USER"

        success "Default shell changed to Zsh."

    fi

else
    warn "Zsh is not installed."
fi

# ==========================================
# 13. POST-INSTALLATION VALIDATION
# ==========================================

info "Running post-installation checks..."

# Check bare repository.

if [[ "$(dotfiles rev-parse --is-bare-repository)" == "true" ]]; then
    success "Bare repository is valid."
else
    warn "Bare repository validation failed."
fi

# Check systemd failed units.

if systemctl --failed --no-legend --no-pager | grep -q .; then
    warn "Some system services have failed."
    systemctl --failed --no-pager
else
    success "No failed system services."
fi

# Check user systemd failed units.

if systemctl --user --failed --no-legend --no-pager | grep -q .; then
    warn "Some user services have failed."
    systemctl --user --failed --no-pager
else
    success "No failed user services."
fi

# Check ZRAM.

if command_exists zramctl; then
    zramctl
fi

# ==========================================
# 14. FINISH
# ==========================================

echo
echo "=================================================="
echo " Installation completed!"
echo "=================================================="
echo
echo " Next steps:"
echo " 1. Review failed services if any."
echo " 2. Check ZRAM: zramctl"
echo " 3. Check swap: swapon --show"
echo " 4. Check user services: systemctl --user --failed"
echo " 5. Log out and log back in."
echo
echo " Installation log:"
echo " $LOG_FILE"
echo
echo "=================================================="
