#!/bin/sh

set -eu

WARNING=80
CRITICAL=90

usage() {
    echo "Usage: $0 [-w WARNING_PERCENT] [-c CRITICAL_PERCENT]"
    exit 3
}

while getopts "w:c:" opt; do
    case "$opt" in
        w) WARNING="$OPTARG" ;;
        c) CRITICAL="$OPTARG" ;;
        *) usage ;;
    esac
done

case "$WARNING" in
    ''|*[!0-9]*) echo "UNKNOWN - warning threshold must be an integer"; exit 3 ;;
esac

case "$CRITICAL" in
    ''|*[!0-9]*) echo "UNKNOWN - critical threshold must be an integer"; exit 3 ;;
esac

if [ "$WARNING" -ge "$CRITICAL" ]; then
    echo "UNKNOWN - warning threshold must be lower than critical threshold"
    exit 3
fi

if [ ! -r /proc/sys/fs/file-nr ]; then
    echo "UNKNOWN - /proc/sys/fs/file-nr is not readable"
    exit 3
fi

set -- $(cat /proc/sys/fs/file-nr)

if [ "$#" -ne 3 ]; then
    echo "UNKNOWN - unexpected /proc/sys/fs/file-nr format"
    exit 3
fi

ALLOCATED="$1"
UNUSED="$2"
MAXIMUM="$3"

if [ "$MAXIMUM" -eq 0 ]; then
    echo "UNKNOWN - maximum file descriptors is zero"
    exit 3
fi

if [ "$ALLOCATED" -gt "$MAXIMUM" ]; then
    echo "UNKNOWN - allocated file descriptors exceed maximum"
    exit 3
fi

USED_PERCENT=$((ALLOCATED * 100 / MAXIMUM))

STATUS=0
STATE="OK"

if [ "$USED_PERCENT" -ge "$CRITICAL" ]; then
    STATUS=2
    STATE="CRITICAL"
elif [ "$USED_PERCENT" -ge "$WARNING" ]; then
    STATUS=1
    STATE="WARNING"
fi

echo "$STATE - file descriptors ${USED_PERCENT}% used | allocated=$ALLOCATED unused=$UNUSED maximum=$MAXIMUM used_percent=$USED_PERCENT%;$WARNING;$CRITICAL;0;100"

exit "$STATUS"
