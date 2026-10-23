#!/bin/bash

set -u

TARGETS=("google.com" "172.66.147.243")
INTERVAL=10
PING_TIMEOUT=5
LOG_FILE="/var/log/network-monitor.log"

if ! touch "$LOG_FILE"; then
    echo "ERROR: Cannot write to $LOG_FILE" >&2
    exit 1
fi

echo "Network Connectivity Monitor started."
echo "Monitoring interval: ${INTERVAL}s"

while true; do
    for TARGET in "${TARGETS[@]}"; do
        TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
        RESULT=$(ping -n -c 1 -W "$PING_TIMEOUT" "$TARGET" 2>/dev/null)
        PING_EXIT=$?

        if [ "$PING_EXIT" -eq 0 ]; then
            STATUS="ONLINE"
            LATENCY=$(echo "$RESULT" | sed -n 's/.*time[=<]\([0-9.]*\).*/\1/p')
            LATENCY="${LATENCY:-unknown}"
        else
            STATUS="OFFLINE"
            LATENCY="N/A"
        fi

        printf '%s,%s,%s,%s\n' "$TIMESTAMP" "$TARGET" "$STATUS" "$LATENCY" >> "$LOG_FILE"
        echo "$TIMESTAMP | $TARGET | $STATUS | Latency: $LATENCY"
    done
    sle
