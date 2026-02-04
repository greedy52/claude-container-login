#!/bin/bash
# Handler script for opening URLs

while IFS= read -r url; do
    if [ -n "$url" ]; then
        echo "[$(date +%H:%M:%S)] Opening: $url" >&2
        open "$url"
    fi
done
