#!/bin/bash

sketchybar --add item apple_logo left \
  --set apple_logo \
  label.drawing=off \
  icon="󰀵" \
  icon.font="DepartureMono Nerd Font:Regular:15.0" \
  padding_right=10 \
  icon.padding_left=9 \
  icon.padding_right=9 \
  icon.color=$ITEM_COLOR \
  background.drawing=on \
  background.color=$ACCENT_COLOR
