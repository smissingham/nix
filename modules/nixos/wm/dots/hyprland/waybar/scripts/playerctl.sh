#!/usr/bin/env bash

# Get player status
status=$(playerctl status 2>/dev/null)

if [ "$status" = "Playing" ]; then
    icon="󰐊"
elif [ "$status" = "Paused" ]; then
    icon="󰏤"
else
    echo ""
    exit 0
fi

# Get artist and title
artist=$(playerctl metadata artist 2>/dev/null)
title=$(playerctl metadata title 2>/dev/null)

# Truncate if too long
max_length=50
if [ -n "$artist" ] && [ -n "$title" ]; then
    output="$icon $artist - $title"
elif [ -n "$title" ]; then
    output="$icon $title"
else
    output="$icon"
fi

# Truncate output if needed
if [ ${#output} -gt $max_length ]; then
    output="${output:0:$max_length}..."
fi

echo "$output"
