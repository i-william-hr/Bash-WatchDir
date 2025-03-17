#!/bin/bash
# Set the directory you want to watch
WATCH_DIR="/var/www/"
# Set the shell script to run on each new file
SCRIPT_TO_RUN="/root/scripts/ftp.sh"

# Check for inotifywait
if ! command -v inotifywait >/dev/null 2>&1; then
    echo "inotifywait not found. Please install inotify-tools."
    exit 1
fi

echo "Watching $WATCH_DIR for new directories and files..."

# Watch recursively for directory creation and file close_write events.
inotifywait -m -r -e create -e close_write --format '%e %w%f' "$WATCH_DIR" | while read EVENT FULLPATH; do
    # If a directory is created, trigger with -d
    if echo "$EVENT" | grep -q "CREATE" && [ -d "$FULLPATH" ]; then
        echo "Creating Directory: $FULLPATH"
        "$SCRIPT_TO_RUN" -d "$FULLPATH"
    fi

    # For files: on close_write event, check that it's a file (not a directory)
    if echo "$EVENT" | grep -q "CLOSE_WRITE" && [ -f "$FULLPATH" ]; then
        echo "File completed: $FULLPATH"
        # Brief pause to ensure the file is fully written
        sleep 1
        # Extra check that the file is no longer in use
        if lsof "$FULLPATH" >/dev/null 2>&1; then
            echo "File $FULLPATH is still in use, skipping."
            continue
        fi
        "$SCRIPT_TO_RUN" -f "$FULLPATH"
    fi
done
