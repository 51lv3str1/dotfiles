#!/bin/bash

sketchybar --add item bluetooth right \
  --set bluetooth \
  update_freq=10 \
  icon="󰂯" \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  icon.color=0xffcdd6f4 \
  icon.font="DepartureMono Nerd Font:Regular:16.0" \
  label.drawing=off \
  icon.padding_left=0 \
  icon.padding_right=0 \
  script="$PLUGIN_DIR/bluetooth.sh"
