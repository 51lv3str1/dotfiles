#!/bin/bash

# ─────────────────────────────────────────────
# Arch Linux Logo Item
# ─────────────────────────────────────────────

sketchybar --add item arch_logo left \
  --set arch_logo \
      label.drawing=off \
      icon="󰣇" \
      icon.font="Hack Nerd Font:Regular:14.4" \
      padding_right=10 \
      icon.padding_left=9\
      icon.padding_right=9 \
      icon.color=$ITEM_COLOR \
      background.drawing=on \
      background.color=$ACCENT_COLOR
