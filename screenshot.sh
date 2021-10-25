#! /bin/bash

set -e

rm -f /tmp/screenshot
gnome-screenshot $@ -cf /tmp/screenshot
cat /tmp/screenshot | xclip -i -selection clipboard -target image/png
