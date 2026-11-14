#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# SETTINGS
# ==========================================

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
CURRENT_USER="$(id -un)"
MODE="${1:-full}"

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

[[ "$MODE" == "full" || "$MODE" == "--user-only" ]] ||
    die "Usage: $0 [--user-only]"

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
        warn "System service not found: $unit"
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

write_managed_file() (
    trap - ERR

    local destination="$1"
    local mode="$2"
    local temp_file
    local backup_file

    temp_file="$(mktemp)"
    trap 'rm -f -- "$temp_file"' EXIT

    cat > "$temp_file"

    if sudo test -f "$destination" &&
        sudo cmp -s "$temp_file" "$destination"; then

        success "Configuration unchanged: $destination"
        return 0
    fi

    if sudo test -e "$destination" ||
        sudo test -L "$destination"; then

        backup_file="${destination}.bak.$(date +%Y%m%d-%H%M%S)"
        sudo cp -a -- "$destination" "$backup_file"

        info "Backup created: $backup_file"
    fi

    sudo install -D -m "$mode" "$temp_file" "$destination"

    success "Configuration written: $destination"
)

# ==========================================
# SYSTEM FUNCTIONS
# ==========================================

install_base_packages() {
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
}

install_application_packages() {
    info "Installing application packages..."

    local pkglist="$HOME/.setup/pkglist.txt"
    local -a packages=()

    if [[ ! -f "$pkglist" ]]; then
        warn "pkglist.txt not found."
        return 0
    fi

    mapfile -t packages < <(
        sed 's/#.*//' "$pkglist" |
            sed 's/^[[:space:]]*//; s/[[:space:]]*$//' |
            awk 'NF && !seen[$0]++'
    )

    if ((${#packages[@]} == 0)); then
        warn "pkglist.txt is empty."
        return 0
    fi

    paru -S --needed --noconfirm "${packages[@]}"

    success "Application packages installed."
}

configure_system_services() {
    info "Configuring system services..."

    enable_system_service NetworkManager.service
    enable_system_service sddm.service
}

configure_zram() {
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

    success "ZRAM configured."
}

configure_caps2esc() {
    info "Configuring CapsLock <-> Escape..."

    for cmd in udevmon intercept caps2esc uinput; do
        command_exists "$cmd" ||
            die "Caps2Esc dependency not found: $cmd"
    done

    write_managed_file /etc/udevmon.yaml 644 <<'EOF'
- JOB: "intercept -g $DEVNODE | caps2esc | uinput -d $DEVNODE"
  DEVICE:
    EVENTS:
      EV_KEY: [KEY_CAPSLOCK, KEY_ESC]
EOF

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

configure_fcitx5_lotus_system() {
    info "Configuring Fcitx5 Lotus system..."

    # Load uinput module
    sudo modprobe uinput

    # Load uinput automatically at boot
    write_managed_file \
        /etc/modules-load.d/uinput.conf \
        644 <<'EOF'
uinput
EOF

    # Apply udev rules
    sudo udevadm control --reload-rules
    sudo udevadm trigger

    success "Fcitx5 Lotus system configured."
}

configure_fcitx5_lotus_user() {
    info "Enabling Fcitx5 Lotus for $CURRENT_USER..."

    enable_user_service "fcitx5-lotus-server@${CURRENT_USER}.service"

    success "Fcitx5 Lotus user service enabled."
}

configure_system_zsh() {
    info "Configuring system Zsh environment..."

    local zshenv="/etc/zsh/zshenv"
    local begin_marker="# BEGIN DOTFILES ZSH CONFIG"
    local end_marker="# END DOTFILES ZSH CONFIG"

    sudo install -d -m 755 /etc/zsh

    if ! sudo test -e "$zshenv" &&
        ! sudo test -L "$zshenv"; then

        sudo install -m 644 /dev/null "$zshenv"
    fi

    if sudo grep -Fq "$begin_marker" "$zshenv"; then

        sudo grep -Fq "$end_marker" "$zshenv" ||
            die "Zsh configuration has an incomplete marker block."

        success "Zsh environment configuration already exists."
        return 0

    elif sudo grep -Fq "$end_marker" "$zshenv"; then

        die "Zsh END marker exists without BEGIN marker."
    fi

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
}

# ==========================================
# USER FUNCTIONS
# ==========================================

validate_dotfiles() {
    info "Validating Bare Dotfiles repository..."

    [[ -d "$DOTFILES_DIR" ]] ||
        die "Bare repository not found: $DOTFILES_DIR"

    [[ "$(git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository)" == "true" ]] ||
        die "Invalid bare repository: $DOTFILES_DIR"

    git --git-dir="$DOTFILES_DIR" rev-parse --verify HEAD >/dev/null 2>&1 ||
        die "Bare repository has no valid HEAD commit."

    success "Bare repository is valid."
}

configure_noctalia() {
    info "Configuring Noctalia..."

    local config="$HOME/.config/noctalia/noctalia-config.toml"

    if [[ ! -f "$config" ]]; then
        warn "Noctalia config not found. Skipping."
        return 0
    fi

    # Replace hardcoded /home/<username> paths.
    sed -i "s|/home/[^/]*|$HOME|g" "$config"

    success "Noctalia configuration updated."
}

configure_yazi() {
    info "Configuring Yazi plugin..."

    if ! command_exists ya; then
        warn "Yazi not installed. Skipping plugin."
        return 0
    fi

    ya pkg add boydaihungst/mediainfo

    success "Yazi mediainfo plugin installed."
}

configure_xdg_directories() {
    info "Configuring XDG User Directories..."

    if ! command_exists xdg-user-dirs-update; then
        warn "xdg-user-dirs-update not found."
        return 0
    fi

    xdg-user-dirs-update

    success "XDG User Directories configured."
}

create_user_directories() {
    info "Creating user directories..."

    mkdir -p \
        "$HOME/Downloads/wallpapers/bing" \
        "$HOME/Downloads/wallpapers/wallhaven"

    success "User directories created."
}

configure_user_services() {
    info "Configuring user services..."

    systemctl --user daemon-reload

    enable_user_service bing-wallpaper.timer
    enable_user_service bing-wallpaper-watcher.service

    success "User services configured."
}

configure_user_zsh() {
    info "Configuring Zsh user directories..."

    install -d -m 700 \
        "$HOME/.local/state/zsh" \
        "$HOME/.cache/zsh"

    success "Zsh user directories created."
}

configure_ibus_cleanup() {
    info "Cleaning up legacy IBus..."

    if command_exists killall; then
        killall ibus-daemon 2>/dev/null || true
    fi

    if command_exists ibus; then
        ibus exit 2>/dev/null || true
    fi

    success "IBus cleanup completed."
}

configure_default_shell() {
    info "Configuring default shell..."

    if ! command_exists zsh; then
        warn "Zsh is not installed."
        return 0
    fi

    local zsh_path
    local current_shell
    local zsh_real
    local current_shell_real

    zsh_path="$(command -v zsh)"

    if ! grep -Fxq "$zsh_path" /etc/shells; then
        warn "Zsh is not listed in /etc/shells: $zsh_path"
        return 0
    fi

    current_shell="$(getent passwd "$CURRENT_USER" | cut -d: -f7)"
    zsh_real="$(readlink -f "$zsh_path")"
    current_shell_real="$(readlink -f "$current_shell")"

    if [[ "$current_shell_real" == "$zsh_real" ]]; then
        success "Zsh is already the default shell."
        return 0
    fi

    chsh -s "$zsh_path"

    success "Default shell changed to Zsh."
}

configure_bing_wallpaper() {
    info "Setting up Bing wallpapers..."

    local script_dir="$HOME/.local/bin"

    for script in bing-wallpapers.sh bing-wallpaper.sh; do
        [[ -f "$script_dir/$script" ]] ||
            die "Script not found: $script_dir/$script"

        chmod +x "$script_dir/$script"
    done

    "$script_dir/bing-wallpapers.sh"
    "$script_dir/bing-wallpaper.sh"

    success "Bing wallpaper setup completed."
}

# ==========================================
# VALIDATION FUNCTIONS
# ==========================================

validate_system() {
    info "Checking system services..."

    local failed

    failed="$(systemctl --failed --no-legend --no-pager)"

    if [[ -n "$failed" ]]; then
        warn "Some system services have failed."
        systemctl --failed --no-pager
    else
        success "No failed system services."
    fi
}

validate_user() {
    info "Checking user services..."

    local failed

    failed="$(systemctl --user --failed --no-legend --no-pager)"

    if [[ -n "$failed" ]]; then
        warn "Some user services have failed."
        systemctl --user --failed --no-pager
    else
        success "No failed user services."
    fi
}

validate_zram() {
    info "Checking ZRAM..."

    if command_exists zramctl; then
        zramctl
    else
        warn "zramctl not found."
    fi
}


# ==========================================
# TRAPS
# ==========================================

trap cleanup EXIT
trap 'on_error "$?" "$LINENO" "$BASH_COMMAND"' ERR

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
# SYSTEM SETUP
# ==========================================

if [[ "$MODE" == "full" ]]; then

    install_base_packages
    install_application_packages

    configure_system_services
    configure_zram
    configure_caps2esc
    configure_fcitx5_lotus_system
    configure_system_zsh

fi

# ==========================================
# USER SETUP
# ==========================================
validate_dotfiles
configure_noctalia
configure_fcitx5_lotus_user

if [[ "$MODE" == "full" ]]; then
    configure_yazi
fi

configure_xdg_directories
create_user_directories
configure_user_services

configure_user_zsh
configure_ibus_cleanup
configure_default_shell
configure_bing_wallpaper

# ==========================================
# POST-INSTALLATION
# ==========================================

info "Running post-installation checks..."

validate_dotfiles
validate_user

if [[ "$MODE" == "full" ]]; then
    validate_system
    validate_zram
fi

info "Installation completed."

printf '\nLog file: %s\n' "$LOG_FILE"
printf 'Please log out and log back in to apply shell and session changes.\n'
