#!/usr/bin/env bash


wallDir="$HOME/Downloads/Wallpapers"
scriptsDir="$HOME/.config/hypr/Script"

wallDir="$HOME/Downloads/Wallpapers"

img=$(fd -e jpg -e png -e webp . "$wallDir" | fzf --preview 'kitten icat --clear \
  --transfer-mode=memory \
  --stdin=no \
  --place ${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES}@0x0 {}')

[ -z "$img" ] && exit 0

# SWWW Config
FPS=60
TYPE="grow"
DURATION=1
BEZIER=".4,0,.2,1"
SWWW_PARAMS="--transition-fps $FPS --transition-type $TYPE --transition-duration $DURATION"

# initiate swww if not running
swww query || swww-daemon --format xrgb


# Set wallpaper
[[ -n "$img" ]] && swww img -o "$focused_monitor" "${img}" $SWWW_PARAMS;


# Run matugen script
sleep 0.5
[[ -n "$img" ]] && "$scriptsDir/matugenMagick.sh" --dark
