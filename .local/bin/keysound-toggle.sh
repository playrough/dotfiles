#!/usr/bin/env bash

KEYSOUND="$HOME/keysound/keysound"
CONFIG="$HOME/keysound/audio/typewriter-key.wav"

if pgrep -x keysound >/dev/null; then
    "$KEYSOUND" -k
    notify-send "Keysound" "OFF"
else
    "$KEYSOUND" -f "$CONFIG" -D
    notify-send "Keysound" "ON"
fi
