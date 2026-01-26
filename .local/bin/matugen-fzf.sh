#!/usr/bin/env bash

WALL_DIR="$HOME/Downloads/Wallpapers"

img=$(fd -e jpg -e png -e webp . "$WALL_DIR" | fzf --preview 'kitten icat --clear \
  --transfer-mode=memory \
  --stdin=no \
  --place ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {}')

[ -z "$img" ] && exit 0

matugen image "$img" && "$HOME/.local/bin/matugen-push.sh"
