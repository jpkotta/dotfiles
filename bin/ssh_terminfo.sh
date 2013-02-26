#!/usr/bin/env bash

if [ -z "$1" ] ; then
    echo "Usage: $0 [USER@]HOST"
    echo "Copies terminfo for urxvt-unicode to a remote machine."
    exit 1
fi

infocmp rxvt-unicode | ssh "$1" "mkdir -p .terminfo && cat > /tmp/ti && tic /tmp/ti"
infocmp rxvt-unicode-256color | ssh "$1" "mkdir -p .terminfo && cat > /tmp/ti && tic /tmp/ti"
