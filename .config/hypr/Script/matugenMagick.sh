#!/usr/bin/env bash

set -euo pipefail

# =========================================================
# PATHS
# =========================================================

wallpaper_path=$(cat ~/.cache/current_wallpaper)

scriptsDir="$HOME/.config/hypr/Script"

temp_frame="/tmp/matugen-frame.png"

# =========================================================
# DETECT VIDEO
# =========================================================

ext="${wallpaper_path##*.}"

case "${ext,,}" in
    mp4|webm|mov|gif)

        ffmpeg -y \
            -i "$wallpaper_path" \
            -frames:v 1 \
            "$temp_frame" \
            -loglevel quiet

        matugen_input="$temp_frame"

        ;;

    *)

        matugen_input="$wallpaper_path"

        ;;
esac

# =========================================================
# MATUGEN
# =========================================================

if [ "${1:-}" == "--light" ]; then
    matugen image "$matugen_input" -m light
else
    matugen image "$matugen_input" -m dark
fi

# =========================================================
# GTK THEME
# =========================================================

gsettings set org.gnome.desktop.interface gtk-theme ""
gsettings set org.gnome.desktop.interface gtk-theme adw-gtk3

# =========================================================
# CREATE HOVER ICONS
# =========================================================

"$scriptsDir/createPngHoverIcon.sh"

# =========================================================
# ROFI IMAGES
# =========================================================

magick "$matugen_input" \
    -strip \
    -resize 1000 \
    -gravity center \
    -extent 1000 \
    -blur "30x30" \
    -quality 90 \
    "$HOME/.config/rofi/images/currentWalBlur.thumb"

magick "$matugen_input" \
    -strip \
    -resize 1000 \
    -gravity center \
    -extent 1000 \
    -quality 90 \
    "$HOME/.config/rofi/images/currentWal.thumb"

magick "$matugen_input" \
    -strip \
    -thumbnail 500x500^ \
    -gravity center \
    -extent 500x500 \
    "$HOME/.config/rofi/images/currentWal.sqre"

magick "$HOME/.config/rofi/images/currentWal.sqre" \
    \( -size 500x500 xc:white \
       -fill "rgba(0,0,0,0.7)" \
       -draw "polygon 400,500 500,500 500,0 450,0" \
       -fill black \
       -draw "polygon 500,500 500,0 450,500" \
    \) \
    -alpha Off \
    -compose CopyOpacity \
    -composite \
    "$HOME/.config/rofi/images/currentWalQuad.png"

mv \
    "$HOME/.config/rofi/images/currentWalQuad.png" \
    "$HOME/.config/rofi/images/currentWalQuad.quad"

# =========================================================
# CURRENT WALLPAPER LINK
# =========================================================

ln -sf "$wallpaper_path" "$HOME/.local/share/bg"

# =========================================================
# NOTIFICATION
# =========================================================

notify-send \
    -e \
    -h string:x-canonical-private-synchronous:matugen_notif \
    "MatugenMagick" \
    "Matugen & ImageMagick completed" \
    -i "$HOME/.local/share/bg"
```
