#!/bin/bash

# ----- Configuration -----
FTP_HOST="xxx
FTP_USER="xxxx"
FTP_PASS="xxxx"
# LOCAL_ROOT is the base path for your local files that maps to the FTP root.
LOCAL_ROOT="/var/www"
# --------------------------

usage() {
    echo "Usage: $0 -d <directory> | -f <file>"
    exit 1
}

# Parse options: either -d for directory or -f for file.
while getopts "d:f:" opt; do
    case $opt in
        d) MODE="dir"; TARGET="$OPTARG" ;;
        f) MODE="file"; TARGET="$OPTARG" ;;
         *) usage ;;
    esac
done

[ -z "$MODE" ] && usage

# Helper function: strip the LOCAL_ROOT prefix if present.
strip_local_root() {
    local path="$1"
    if [[ "$path" == "$LOCAL_ROOT"* ]]; then
         # Remove the LOCAL_ROOT and any leading slash.
         echo "${path#$LOCAL_ROOT/}"
    else
         echo "$path"
    fi
}

if [ "$MODE" == "dir" ]; then
    # Create a remote directory.
    REMOTE_DIR=$(strip_local_root "$TARGET")
    echo "Creating remote directory: $REMOTE_DIR on $FTP_HOST"
    curl "ftp://$FTP_HOST/" --user "$FTP_USER:$FTP_PASS" --quote "MKD $REMOTE_DIR"
elif [ "$MODE" == "file" ]; then
    # Upload a file. If the file is in a subdirectory relative to LOCAL_ROOT, ensure the directory exists.
    LOCAL_FILE="$TARGET"
    REMOTE_PATH=$(strip_local_root "$TARGET")

    # Extract directory and file name.
    REMOTE_DIR=$(dirname "$REMOTE_PATH")
    REMOTE_FILE=$(basename "$REMOTE_PATH")

    # If the file is in a subdirectory, ensure that directory exists on the FTP server.
    if [ "$REMOTE_DIR" != "." ]; then
        echo "Ensuring remote directory $REMOTE_DIR exists on $FTP_HOST"
        curl "ftp://$FTP_HOST/" --user "$FTP_USER:$FTP_PASS" --quote "MKD $REMOTE_DIR"
        REMOTE_URI="ftp://$FTP_HOST/$REMOTE_DIR/$REMOTE_FILE"
    else
        REMOTE_URI="ftp://$FTP_HOST/$REMOTE_FILE"
    fi

    echo "Uploading $LOCAL_FILE to $REMOTE_URI"
    curl -T "$LOCAL_FILE" "$REMOTE_URI" --user "$FTP_USER:$FTP_PASS"
else
    usage
fi
root@jerusalem:~/scripts#
