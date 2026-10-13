#!/bin/sh
# Build ESP32 firmware with a lower UART baud into firmware/esp32-<baud>/.
# Needs the pinned ESP-IDF (see firmware-targets.json) activated: . export.sh
set -eu
baud=${1:?usage: build.sh <baud>}
here=$(cd "$(dirname "$0")" && pwd)
repo=$(cd "$here/../.." && pwd)
[ -n "${IDF_PATH:-}" ] || { echo "Activate ESP-IDF first" >&2; exit 1; }
[ -e "$repo/components/esp-dsp/CMakeLists.txt" ] || git -C "$repo" submodule update --init --depth 1 components/esp-dsp
build=$here/build/$baud
mkdir -p "$build"
sed "s/^CONFIG_ESP_SDR_UART_BAUD=.*/CONFIG_ESP_SDR_UART_BAUD=$baud/" \
    "$repo/sdkconfig.defaults.esp32" > "$build/defaults"
cd "$repo"
IDF_COMPONENT_MANAGER=0 idf.py -B "$build" -DIDF_TARGET=esp32 \
    -DSDKCONFIG="$build/sdkconfig" -DSDKCONFIG_DEFAULTS="$build/defaults" \
    -DESP_SDR_STREAMING=OFF -DRING_PROBE=OFF -DSAMPLE_RATE_PROBE=OFF \
    -DFILTER_REGISTER_PROBE=OFF -DS3_RF_PROBE=OFF -DC5_TUNE_PROBE=OFF \
    -DS2_RF_PROBE=OFF build
out=$here/firmware/esp32-$baud
mkdir -p "$out"
cp "$build/bootloader/bootloader.bin" "$build/partition_table/partition-table.bin" \
   "$build/esp_sdr.bin" "$out/"
echo "Firmware: $out"
