#!/usr/bin/env bash

if [ -z "$1" ] ; then
    echo "Usage: $0 [USER@]HOST"
    echo "Copies terminfo for urxvt-unicode to a remote machine."
    exit 1
fi

ssh "$1" "mkdir -p .terminfo/r"
scp /usr/share/terminfo/r/rxvt-unicode* "$1":.terminfo/r/
