#!/usr/bin/env bash

LOGO_DIR="$HOME/.config/fastfetch/logo/guardian_tales/"

# Nếu thư mục không tồn tại thì exit
[ -d "$LOGO_DIR" ] || exit 0

# Random 1 file bất kỳ
find "$LOGO_DIR" -type f | shuf -n 1
