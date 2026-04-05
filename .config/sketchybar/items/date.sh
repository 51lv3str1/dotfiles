#!/bin/bash

sketchybar --set "$NAME" label="$(date '+%a %-d' | awk '{print tolower($0)}')"
