# Toggle-Audio-Sink

This script allows you to toggle between available audio output devices (sinks) in systems using PulseAudio. It dynamically switches the default audio sink and moves all active audio streams to the selected sink.

## Features

- Detects all available audio sinks using PulseAudio.
- Switches to the next audio sink in a loop.
- Moves active audio streams to the selected sink.
- Provides user feedback via desktop notifications or terminal output.

## Requirements

- GhostBSD (MATE desktop environment recommended).
- PulseAudio installed and running.
- `pactl` command available (part of PulseAudio utilities).
- Optional: `notify-send` for desktop notifications.

## Installation

1. **Download the Script**  
   Save the script as `toggle_audio_sink.sh`.

2. **Move to `/usr/local/bin`**  
   Move the script to a directory in your `$PATH` for system-wide availability:
   ```bash
   sudo mv toggle_audio_sink.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/toggle_audio_sink.sh
   ```

3. **Test the Script**  
   Run the script to ensure it works:
   ```bash
   /usr/local/bin/toggle_audio_sink.sh
   ```

---

## Integration with GhostBSD MATE Desktop

You can integrate the script with GhostBSD’s MATE desktop environment by binding it to a custom keyboard shortcut:

### Steps

1. **Open Keyboard Shortcuts**  
   Navigate to the keyboard shortcut settings:
   - **System > Preferences > Keyboard Shortcuts**

2. **Add a Custom Shortcut**  
   - Click **Add** or **Custom Shortcut** (depending on your version).
   - **Name**: `Toggle Audio Sink`
   - **Command**: `/usr/local/bin/toggle_audio_sink.sh`

3. **Assign a Hotkey**  
   - After creating the shortcut, click the **Shortcut** column next to the new entry.
   - Press your desired key combination (e.g., `Ctrl+Alt+S`).

4. **Test the Hotkey**  
   Press the assigned key combination to toggle between audio sinks.

---

## Script Details

### How It Works

1. **Retrieve Available Sinks**:  
   The script lists all available sinks using:
   ```bash
   pactl list short sinks
   ```

2. **Switch to the Next Sink**:  
   It determines the next sink in the list, cycling back to the first sink when reaching the end.

3. **Set the Default Sink**:  
   The selected sink is set as the default using:
   ```bash
   pactl set-default-sink <sink_name>
   ```

4. **Move Active Streams**:  
   All active audio streams are moved to the new sink:
   ```bash
   pactl move-sink-input <stream_index> <sink_name>
   ```

5. **Notify the User**:  
   If `notify-send` is installed, a desktop notification is displayed. Otherwise, a message is printed to the terminal.

---

### Script Code

```bash
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
```

---

## Troubleshooting

- **No Sinks Detected**:  
  Ensure PulseAudio is running:
  ```bash
  pulseaudio --start
  ```

- **Audio Does Not Switch**:  
  - Check active streams:
    ```bash
    pactl list short sink-inputs
    ```
  - Move streams manually using:
    ```bash
    pactl move-sink-input <stream_index> <sink_name>
    ```

- **Notifications Not Shown**:  
  Install `notify-send`:
  ```bash
  sudo pkg install libnotify
  ```

---

## Contributions

Feel free to contribute by submitting a pull request or opening an issue!
