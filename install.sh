#!/usr/bin/env bash
set -Eeuo pipefail

REPO="https://github.com/playrough/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [[ -e "$DOTFILES_DIR" ]]; then
    echo "[ERROR] Dotfiles directory already exists: $DOTFILES_DIR"
    exit 1
fi

echo "==> Cloning dotfiles..."

git clone --bare "$REPO" "$DOTFILES_DIR"

git --git-dir="$DOTFILES_DIR" config --local status.showUntrackedFiles no

echo "==> Checking out dotfiles..."

if ! git --git-dir="$DOTFILES_DIR"  \
    --work-tree="$HOME" checkout; then

    echo "[ERROR] Dotfiles checkout failed."
    echo "Resolve existing file conflicts and run the installer again."
    exit 1
fi

echo "==> Running setup..."

bash "$HOME/setup.sh"
