#!/usr/bin/env bash
set -Eeuo pipefail

REPO="https://github.com/playrough/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"

if [[ -e "$DOTFILES_DIR" ]]; then
    echo "Dotfiles directory already exists: $DOTFILES_DIR"
    exit 1
fi

git clone --bare "$REPO" "$DOTFILES_DIR"

git --git-dir="$DOTFILES_DIR" config --local status.showUntrackedFiles no

git --git-dir="$DOTFILES_DIR" \
    --work-tree="$HOME" \
    checkout -- install.sh

bash "$HOME/setup.sh"
