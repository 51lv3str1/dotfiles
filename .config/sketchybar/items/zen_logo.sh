#!/bin/bash

sketchybar --add item zen_logo right \
  --set zen_logo \
  label.drawing=off \
  icon="永" \
  icon.font="DepartureMono Nerd Font:Bold:13.2" \
  icon.color=$ITEM_COLOR \
  icon.padding_left=12 \
  icon.padding_right=12 \
  background.drawing=on \
  background.color=$ACCENT_COLOR \
  background.corner_radius=6
