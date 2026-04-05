#!/bin/bash

sketchybar --add item time q \
  --set time \
  icon.drawing=off \
  update_freq=1 \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  label.padding_left=10 \
  label.padding_right=10 \
  script="$PLUGIN_DIR/time.sh"
