#!/usr/bin/env bash
# https://github.com/nekwebdev/calis
# @nekwebdev
# LICENSE: GPLv3
#
# chococinema.sh
#
# script to start an asciinema recording.
#

pacman --noconfirm --needed -Sy asciinema
rm -rf ~/chocolate.cast
asciinema rec --stdin -i 5 ~/chocolate.cast
