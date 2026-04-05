#!/bin/bash

sketchybar --add item battery right \
  --set battery \
  update_freq=60 \
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
  script="$PLUGIN_DIR/battery.sh" \
  --subscribe battery system_woke power_source_change
