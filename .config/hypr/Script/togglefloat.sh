#!/usr/bin/env bash

hyprctl dispatch togglefloating

if hyprctl activewindow | grep -Eq "class: (kitty|org.kde.dolphin|nemo|Code)" && \
    hyprctl activewindow | grep -q "floating: 1";
then
    hyprctl dispatch resizeactive exact 890 520
    hyprctl dispatch centerwindow
fi
