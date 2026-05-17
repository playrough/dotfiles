#!/usr/bin/env bash

# =========================================================
# WallSelect Hybrid Fast
# Image  -> awww
# Video  -> mpvpaper
# GIF    -> mpvpaper
# Optimized for instant rofi open
# =========================================================

set -euo pipefail

# =========================================================
# DIRS
# =========================================================

wall_dir="$HOME/Downloads/Wallpapers"
cacheDir="$HOME/.cache/wallcache"
scriptsDir="$HOME/.config/hypr/Script"

mkdir -p "$cacheDir"

# =========================================================
# MONITOR INFO
# =========================================================

focused_monitor=$(hyprctl monitors -j | jq -r '.[] | select(.focused) | .name')

monitor_width=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" \
'.[] | select(.name == $mon) | .width')

scale_factor=$(hyprctl monitors -j | jq -r --arg mon "$focused_monitor" \
'.[] | select(.name == $mon) | .scale')

# =========================================================
# ROFI
# =========================================================

icon_size=$(echo "scale=2; ($monitor_width * 14) / ($scale_factor * 96)" | bc)

rofi_override="element-icon{size:${icon_size}px;}"

rofi_command="rofi -i -show -dmenu \
-theme $HOME/.config/rofi/applets/wallSelect.rasi \
-theme-str $rofi_override"

# =========================================================
# PARALLEL JOBS
# =========================================================

get_optimal_jobs() {
    local cores
    cores=$(nproc)

    (( cores <= 2 )) && echo 2 || echo $(( (cores > 4) ? 4 : cores - 1 ))
}

PARALLEL_JOBS=$(get_optimal_jobs)

# =========================================================
# THUMBNAIL GENERATOR
# =========================================================

process_media() {
    local media="$1"

    local filename
    filename=$(basename "$media")

    local base_name="${filename%.*}"
    local ext="${filename##*.}"

    local cache_file="${cacheDir}/${base_name}.png"
    local hash_file="${cacheDir}/.${base_name}.hash"
    local lock_file="${cacheDir}/.lock_${base_name}"

    # =====================================================
    # FAST HASH
    # filesize + modified time
    # MUCH faster than xxh64sum on videos
    # =====================================================

    local current_hash
    current_hash="$(stat -c '%s-%Y' "$media")"

    (
        flock -x 200

        if [ ! -f "$cache_file" ] || \
           [ ! -f "$hash_file" ] || \
           [ "$current_hash" != "$(cat "$hash_file" 2>/dev/null)" ]; then

            case "${ext,,}" in

                mp4|webm|mov|gif)

                    ffmpeg -y \
                        -ss 00:00:05 \
                        -i "$media" \
                        -vframes 1 \
                        -vf "scale=800:450:force_original_aspect_ratio=increase,crop=800:450" \
                        "$cache_file" \
                        -loglevel quiet

                    ;;

                *)

                    magick "$media" \
                        -resize 800x450^ \
                        -gravity center \
                        -extent 800x450 \
                        \( -size 800x450 xc:none \
                           -draw "roundrectangle 0,0 800,450 24,24" \) \
                        -alpha set \
                        -compose DstIn \
                        -composite \
                        "$cache_file"

                    ;;
            esac

            echo "$current_hash" > "$hash_file"
        fi

        rm -f "$lock_file"

    ) 200>"$lock_file"
}

export -f process_media
export wall_dir cacheDir

# =========================================================
# CLEAN OLD LOCKS
# =========================================================

rm -f "${cacheDir}"/.lock_* 2>/dev/null || true

# =========================================================
# GENERATE CACHE IN BACKGROUND
# =========================================================

(
find "$wall_dir" -type f \
\( \
    -iname "*.jpg"  -o \
    -iname "*.jpeg" -o \
    -iname "*.png"  -o \
    -iname "*.webp" -o \
    -iname "*.gif"  -o \
    -iname "*.mp4"  -o \
    -iname "*.webm" -o \
    -iname "*.mov" \
\) -print0 | \
xargs -0 -P "$PARALLEL_JOBS" -I {} bash -c 'process_media "{}"'
) &

# =========================================================
# CLEAN ORPHAN CACHE
# =========================================================

(
for cached in "$cacheDir"/*.png; do
    [ -f "$cached" ] || continue

    base="$(basename "${cached%.png}")"

    if ! find "$wall_dir" -type f -iname "$base.*" | grep -q .; then
        rm -f \
            "$cached" \
            "${cacheDir}/.${base}.hash" \
            "${cacheDir}/.lock_${base}"
    fi
done

rm -f "${cacheDir}"/.lock_* 2>/dev/null || true
) &

# =========================================================
# KILL OLD ROFI
# =========================================================

if pidof rofi >/dev/null; then
    pkill rofi
fi

# =========================================================
# FALLBACK ICON
# =========================================================

fallback_icon="$HOME/.config/rofi/images/fallback.png"

# =========================================================
# ROFI MENU
# =========================================================

wall_selection=$(
find "$wall_dir" -type f \
\( \
    -iname "*.jpg"  -o \
    -iname "*.jpeg" -o \
    -iname "*.png"  -o \
    -iname "*.webp" -o \
    -iname "*.gif"  -o \
    -iname "*.mp4"  -o \
    -iname "*.webm" -o \
    -iname "*.mov" \
\) -print0 |
xargs -0 basename -a |
LC_ALL=C sort -V |
while IFS= read -r file; do

    thumb="$cacheDir/${file%.*}.png"

    if [ ! -f "$thumb" ]; then
        thumb="$fallback_icon"
    fi

    printf '%s\x00icon\x1f%s\n' \
        "$file" \
        "$thumb"

done | $rofi_command
)

# =========================================================
# EXIT IF EMPTY
# =========================================================

[[ -z "${wall_selection:-}" ]] && exit 0

selected="${wall_dir}/${wall_selection}"

# =========================================================
# SAVE CURRENT WALLPAPER
# =========================================================

echo "$selected" > ~/.cache/current_wallpaper

# =========================================================
# AWWW CONFIG
# =========================================================

FPS=60
TYPE="fade"
DURATION=1

AWWW_PARAMS=" \
--transition-fps $FPS \
--transition-type $TYPE \
--transition-duration $DURATION"

# =========================================================
# START AWWW
# =========================================================

pgrep awww-daemon >/dev/null || awww-daemon --format xrgb

# =========================================================
# SET WALLPAPER
# =========================================================

ext="${selected##*.}"

case "${ext,,}" in

    mp4|webm|mov|gif)

        pkill mpvpaper 2>/dev/null || true

        awww clear

        mpvpaper \
        -o "loop \
        no-audio \
        hwdec=auto-copy-safe \
        profile=fast \
        interpolation=no \
        video-sync=display-desync \
        scale=bilinear \
        cscale=no \
        deband=no" \
        "$focused_monitor" \
        "$selected" &

        ;;

    *)

        pkill mpvpaper 2>/dev/null || true

        awww img \
        -o "$focused_monitor" \
        "$selected" \
        $AWWW_PARAMS

        ;;
esac

# =========================================================
# RUN MATUGEN
# =========================================================

sleep 0.3

"$scriptsDir/matugenMagick.sh" --dark
