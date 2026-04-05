#!/bin/bash

sketchybar --add item wifi right \
  --set wifi \
  update_freq=30 \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  icon.color=0xffcdd6f4 \
  label.drawing=off \
  icon.padding_left=5 \
  icon.padding_right=0 \
  script="$PLUGIN_DIR/wifi.sh"
