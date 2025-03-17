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
# Check Script exists
if [ ! -f "$SCRIPT_TO_RUN" ]; then
    echo "Script not found."
    exit 1
fi

echo "$(date) - WATCHDIR: Started"
echo "$(date) - WATCHDIR: Watching $WATCH_DIR for new directories and files..."

# Watch recursively for directory creation and file close_write events.
inotifywait -q -m -r -e create -e close_write --format '%e %w%f' "$WATCH_DIR" | while read EVENT FULLPATH; do
    # If a directory is created, trigger with -d
    if echo "$EVENT" | grep -q "CREATE" && [ -d "$FULLPATH" ]; then
        REMOTE=$(basename "$FULLPATH")
	echo "$(date) - WATCHDIR: Directory found - Creating: $REMOTE"
	echo "$(date) - WATCHDIR: Running Script: $SCRIPT_TO_RUN -f $FULLPATH"
        "$SCRIPT_TO_RUN" -d "$FULLPATH"
        echo "$(date) - WATCHDIR: Directory created: $REMOTE"
    fi

    # For files: on close_write event, check that it's a file (not a directory)
    if echo "$EVENT" | grep -q "CLOSE_WRITE" && [ -f "$FULLPATH" ]; then
	REMOTE=$(basename "$FULLPATH")
	echo
        echo "$(date) - WATCHDIR: File found - Copying: $REMOTE"
        sleep 5
    	while lsof "$FULLPATH" >/dev/null 2>&1; do
         echo "$(date) - WATCHDIR: File $FULLPATH is still in use, waiting..."
         sleep 5
        done
	echo "$(date) - WATCHDIR: Running Script: $SCRIPT_TO_RUN -f $FULLPATH"
	echo
        "$SCRIPT_TO_RUN" -f "$FULLPATH"
        echo "$(date) - WATCHDIR: Completed: $REMOTE"
	sleep 2
	echo "$(date) - WATCHDIR: Looping..."
	echo
fi

done
