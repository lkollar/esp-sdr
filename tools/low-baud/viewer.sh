#!/bin/sh
# Fetch the hosted viewer, patch it for a fixed low baud, serve on localhost.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
base=https://espargos.net/espsdr/app
v=$here/viewer
if [ ! -f "$v/radio.js" ]; then
    mkdir -p "$v"
    for f in index.html app.js radio.js serial-transport.js style.css fonts.css \
             espargos-logo.svg favicon-16x16.png favicon-32x32.png favicon-194x194.png; do
        curl -fsSL "$base/$f" -o "$v/$f"
    done
    patch -s "$v/radio.js" "$here/viewer.patch"
fi
echo "Open http://127.0.0.1:8765/?baud=115200 in Chrome"
exec python3 -m http.server 8765 --bind 127.0.0.1 --directory "$v"
