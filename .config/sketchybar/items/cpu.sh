#!/bin/bash

sketchybar --add item cpu right \
  --set cpu \
  update_freq=15 \
  icon="󰘚" \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  icon.color=0xffcdd6f4 \
  label.color=0xffcdd6f4 \
  icon.padding_left=8 \
  icon.padding_right=4 \
  label.padding_left=2 \
  label.padding_right=8 \
  script="$PLUGIN_DIR/cpu.sh"
