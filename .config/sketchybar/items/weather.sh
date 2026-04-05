#!/bin/bash

sketchybar --add item weather e \
  --set weather \
  icon.drawing=on \
  update_freq=1800 \
  background.drawing=on \
  background.color=0xff1e1e2e \
  background.corner_radius=10 \
  background.height=28 \
  label.padding_left=0 \
  label.padding_right=10 \
  icon.padding_left=10 \
  label.y_offset=1 \
  icon.y_offset=2 \
  script="$PLUGIN_DIR/weather.sh"
