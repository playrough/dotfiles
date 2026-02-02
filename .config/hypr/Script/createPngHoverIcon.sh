#!/usr/bin/env bash

# ---------- CONFIG ----------
CSS_PATH="$HOME/.config/waybar/colors.css"
ICON_DIR="$HOME/.config/wlogout/icons"
ALPHA=0.5   # 0.0 → 1.0
# ----------------------------

# --- 1) Lấy màu surface từ matugen colors.css ---
if [ ! -f "$CSS_PATH" ]; then
  echo "Không tìm thấy $CSS_PATH"
  exit 1
fi

SURFACE=$(grep -oP '@define-color\s+surface\s+#[0-9A-Fa-f]+' "$CSS_PATH" \
          | head -n1 \
          | grep -oP '#[0-9A-Fa-f]{6}')

if [ -z "$SURFACE" ]; then
  echo "Không lấy được màu surface từ colors.css"
  exit 1
fi

echo "Surface color: $SURFACE"

# --- 2) Tạo hover icons ---
if [ ! -d "$ICON_DIR" ]; then
  echo "Không tìm thấy thư mục icons: $ICON_DIR"
  exit 1
fi

for f in "$ICON_DIR"/*.png; do
  [ -e "$f" ] || continue
  [[ "$f" == *-hover.png ]] && continue

  hover="${f%.png}-hover.png"

  echo "→ Tạo $(basename "$hover")"

  magick "$f" \
    -alpha on \
    -fill "$SURFACE" \
    -colorize 95% \
    "$hover"
done

echo "✔ Hoàn tất tạo hover icons cho wlogout"
