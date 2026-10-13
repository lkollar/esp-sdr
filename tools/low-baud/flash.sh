#!/bin/sh
# Flash firmware/esp32-<baud>/ at 115200 (higher esptool rates are unreliable
# on some bridges).
set -eu
port=${1:?usage: flash.sh <port> <baud>}
baud=${2:?usage: flash.sh <port> <baud>}
dir=$(cd "$(dirname "$0")" && pwd)/firmware/esp32-$baud
[ -d "$dir" ] || { echo "No firmware in $dir; run build.sh $baud" >&2; exit 1; }
exec esptool --chip esp32 --port "$port" --baud 115200 write-flash \
    --flash-mode dio --flash-size 2MB --flash-freq 40m \
    0x1000 "$dir/bootloader.bin" 0x8000 "$dir/partition-table.bin" \
    0x10000 "$dir/esp_sdr.bin"
