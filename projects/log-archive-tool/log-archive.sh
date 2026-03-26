#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./log-archive.sh <log-directory>

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <log-directory>"
  exit 1
fi

LOG_DIR="$1"

if [ ! -d "$LOG_DIR" ]; then
  echo "Error: Directory '$LOG_DIR' does not exist."
  exit 1
fi

if [ ! -r "$LOG_DIR" ]; then
  echo "Error: Directory '$LOG_DIR' is not readable."
  exit 1
fi

TIMESTAMP="$(date +"%Y%m%d_%H%M%S")"
ARCHIVE_BASE="$(basename "$LOG_DIR")"
ARCHIVE_DIR="$HOME/log-archives"
ARCHIVE_NAME="${ARCHIVE_BASE}_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="${ARCHIVE_DIR}/${ARCHIVE_NAME}"
HISTORY_LOG="${ARCHIVE_DIR}/archive-history.log"

mkdir -p "$ARCHIVE_DIR"

# Create compressed archive
tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

# Log the archive operation
echo "$(date +"%Y-%m-%d %H:%M:%S") | Archived '$LOG_DIR' -> '$ARCHIVE_PATH'" >> "$HISTORY_LOG"

echo "Archive created successfully:"
echo "$ARCHIVE_PATH"
echo "Archive log updated:"
echo "$HISTORY_LOG"
