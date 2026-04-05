#!/bin/bash

CPU_PERCENT=$(ps -eo pcpu | awk -v core_count=$(sysctl -n machdep.cpu.thread_count) '{sum+=$1} END {printf "%.0f\n", sum/core_count}')
sketchybar --set $NAME label="${CPU_PERCENT}%"
