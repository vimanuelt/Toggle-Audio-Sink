#!/bin/sh

# Get the list of available sinks
sinks=$(pactl list short sinks | awk '{print $2}')

# Get the current default sink
current_sink=$(pactl get-default-sink)

# Determine the next sink in the list
next_sink=""
found_current=0
for sink in $sinks; do
    if [ "$sink" = "$current_sink" ]; then
        found_current=1
        continue
    fi
    if [ "$found_current" -eq 1 ]; then
        next_sink=$sink
        break
    fi
done

# If no next sink is found, loop back to the first sink
if [ -z "$next_sink" ]; then
    next_sink=$(echo "$sinks" | head -n 1)
fi

# Set the next sink as default
pactl set-default-sink "$next_sink"

# Move all active audio streams to the new default sink
pactl list short sink-inputs | awk '{print $1}' | while read stream; do
    pactl move-sink-input "$stream" "$next_sink"
done

# Notify the user
if command -v notify-send >/dev/null 2>&1; then
    notify-send "Audio Output Switched" "Now using sink: $next_sink"
else
    echo "Switched to sink: $next_sink"
fi
