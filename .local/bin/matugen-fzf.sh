#!/usr/bin/env bash
#
# WALL_DIR="$HOME/Downloads/Wallpapers"
#
# img=$(fd -e jpg -e png . "$WALL_DIR" | fzf)
#
# [ -z "$img" ] && exit 0
#
# matugen image "$img"
#

WALL_DIR="$HOME/Downloads/Wallpapers"

img=$(fd -e jpg -e png . "$WALL_DIR" | fzf --bind "ctrl-i:execute(feh -B black --scale-down --geometry 1600x900 {})")

[ -z "$img" ] && exit 0

swww img "$img" --transition-type wipe
matugen image "$img"
