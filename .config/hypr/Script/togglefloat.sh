#!/usr/bin/env bash

# bật/tắt floating cho cửa sổ hiện tại
hyprctl dispatch togglefloating

# nếu sau togglefloating cửa sổ đang floating thì resize + center
if hyprctl activewindow | grep -q "floating: 1"; then
    hyprctl dispatch resizeactive exact 890 520
    hyprctl dispatch centerwindow
fi
