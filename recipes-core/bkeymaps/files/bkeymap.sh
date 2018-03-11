#!/bin/sh

if [ -f /usr/share/bkeymaps/de/de.bmap ]; then
    /sbin/loadkmap < /usr/share/bkeymaps/de/de.bmap
fi
