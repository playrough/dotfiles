#!/usr/bin/env bash
set -Eeuo pipefail

# ==========================================
# MODE SELECTION
# ==========================================

echo "================================"
echo "       DOTFILES INSTALLER"
echo "================================"
echo
echo "Select installation mode:"
echo
echo "  1) Full installation"
echo "  2) User configuration only"
echo

read -rp "Choose [1-2]: " choice

case "$choice" in
    1) MODE="full" ;;
    2) MODE="user" ;;
    *)
        echo "[ERROR] Invalid selection."
        exit 1
        ;;
esac

echo
echo "==> Selected mode: $MODE"

# ==========================================
# PRE-FLIGHT
# ==========================================

if [[ "$MODE" == "full" ]]; then
    for cmd in sudo pacman; do
        command -v "$cmd" >/dev/null 2>&1 || {
            echo "[ERROR] Required command not found: $cmd"
            exit 1
        }
    done

    sudo -v
fi

if ! command -v git >/dev/null 2>&1; then
    if [[ "$MODE" == "full" ]]; then
        sudo pacman -S --needed --noconfirm git
    else
        echo "[ERROR] Git is required for user mode."
        exit 1
    fi
fi

# ==========================================
# SETTINGS
# ==========================================

REPO="https://github.com/playrough/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

# ==========================================
# DOTFILES
# ==========================================

if [[ -e "$DOTFILES_DIR" || -L "$DOTFILES_DIR" ]]; then

    [[ -d "$DOTFILES_DIR" ]] ||
        { echo "[ERROR] Invalid dotfiles path."; exit 1; }

    [[ "$(git --git-dir="$DOTFILES_DIR" rev-parse --is-bare-repository 2>/dev/null)" == "true" ]] ||
        { echo "[ERROR] Existing path is not a bare repository."; exit 1; }

    echo "==> Existing bare repository found. Reusing it..."

else
    echo "==> Cloning dotfiles..."
    git clone --bare "$REPO" "$DOTFILES_DIR"
fi

git --git-dir="$DOTFILES_DIR" config --local status.showUntrackedFiles no

echo "==> Checking out dotfiles..."

if ! git --git-dir="$DOTFILES_DIR" \
    --work-tree="$HOME" checkout; then

    echo "[ERROR] Dotfiles checkout failed."
    echo "Resolve existing file conflicts and run the installer again."
    exit 1
fi

# ==========================================
# SETUP
# ==========================================

echo "==> Running setup..."

if [[ "$MODE" == "user" ]]; then
    bash "$HOME/.setup/setup.sh" --user-only
else
    bash "$HOME/.setup/setup.sh"
fi

echo "==> Installation completed."
