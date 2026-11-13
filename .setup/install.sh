#!/usr/bin/env bash
set -Eeuo pipefail

for cmd in sudo pacman; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "[ERROR] Required command not found: $cmd"
        exit 1
    }
done

sudo -v

if ! command -v git >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm git
fi

REPO="https://github.com/playrough/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

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

echo "==> Running setup..."
bash "$HOME/setup.sh"
