# Low-baud workaround for USB-UART bridges

The stock ESP32 firmware and the hosted viewer use 2 Mbaud (viewer falls back
to 1 Mbaud). Some USB-UART bridges cannot do that (tested: two bridges on
macOS, ESP32-D0WDQ6 and ESP32-PICO-D4). Symptoms: web flasher cannot set the
UART speed; viewer reports "SDR synchronization failed".

Tested on ESP32-PICO-D4 (40 MHz, UART0 GPIO1/GPIO3):

| Baud | Result |
| --- | --- |
| 115200 | Works: handshake, 8/10-bit IQ captures, spectrum, CRC clean |
| 230400, 460800, 921600 | Sync fails |
| 1M, 2M | No reply |

The firmware has no runtime baud below 1M, so the baud is a build option
(`CONFIG_ESP_SDR_UART_BAUD`), and the viewer must open at the same rate.
An FT232 adapter or a native-USB chip avoids all this.

## Use

```sh
# ESP-IDF pinned in firmware-targets.json, activated (. export.sh)
tools/low-baud/build.sh 115200          # -> firmware/esp32-115200/
tools/low-baud/flash.sh /dev/cu.usbserial-XXXX 115200
tools/low-baud/viewer.sh                # patched viewer on localhost
```

Open http://127.0.0.1:8765/?baud=115200 in Chrome, then Connect ESP-SDR and
pick the port. Close other serial users first. `firmware/`, `build/` and
`viewer/` are untracked.

`viewer.patch` changes `radio.js` only: baud from `?baud=`, no 2M/1M
fallback, 4 s wait after the reset on connect.

Notes: esptool also needs 115200 on these bridges. Opening the port resets
the board, so wait about 4 s before sending commands. Needs the `esp-dsp`
submodule (`build.sh` initialises it).
