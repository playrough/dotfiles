#!/usr/bin/env bash

TARGET_SYMLINK="$HOME/Downloads/wallpapers/bing/latest.jpg"
TARGET_DIR="$(dirname "$TARGET_SYMLINK")"
TARGET_NAME="$(basename "$TARGET_SYMLINK")"

echo "[INFO] Monitoring wallpaper changes at: $TARGET_SYMLINK..."

inotifywait -m -e create -e moved_to -e close_write --format "%f" "$TARGET_DIR" | while read -r filename; do

  if [ "$filename" = "$TARGET_NAME" ]; then
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [EVENT] Bing symlink updated."

    REAL_IMAGE_PATH=$(readlink -f "$TARGET_SYMLINK")

    echo "[INFO] Resolving symlink target to: $REAL_IMAGE_PATH"
    echo "Triggering Noctalia IPC..."

    noctalia msg wallpaper-set "$REAL_IMAGE_PATH"

    echo "[SUCCESS] Wallpaper successfully updated."
  fi
done
