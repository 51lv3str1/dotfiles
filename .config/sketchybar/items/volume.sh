#!/bin/bash

sketchybar --add item volume right \
  --set volume \
  update_freq=5 \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  icon.font="DepartureMono Nerd Font:Regular:16.0" \
  background.height=28 \
  icon.color=0xffcdd6f4 \
  label.drawing=off \
  icon.padding_left=0 \
  icon.padding_right=8 \
  script="$PLUGIN_DIR/volume.sh" \
  --subscribe volume volume_change
