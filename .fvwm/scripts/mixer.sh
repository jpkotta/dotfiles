#!/bin/bash

debug=0
quiet=1
#feedback_cmd="artsplay $HOME/.fvwm/data/sounds/wipe.wav"

switch_id=`amixer controls | grep 'Master Playback Switch' | cut -d, -f 1`
switch_val=`amixer cget $switch_id | grep ':[[:space:]]*values' | grep -oE 'on|off'`

volume_id=`amixer controls | grep 'Master Playback Volume' | cut -d, -f 1`
volume_val=`amixer cget $volume_id | grep ':[[:space:]]*values' | grep -oE '[0-9]{1,},' | sed -e 's/,//'`

if [[ $debug == 1 ]] ; then
    echo "initial state = $switch_val"
    echo "initial volume = $volume_val"
fi

function update
{   if [[ $debug == 1 ]] ; then
        echo "new state = $switch_val"
        echo "new volume = $volume_val"
    fi
    amixer cset $switch_id $switch_val >& /dev/null
    amixer cset $volume_id $volume_val,$volume_val >& /dev/null

    if [[ -n "$feedback_cmd" ]] ; then
        $feedback_cmd
    fi
}

if [[ "$1" == "incr" ]] ; then
    # doesn't care if volume goes over max
    volume_val=$((volume_val + 2))
elif [[ "$1" == "decr" ]] ; then
    # doesn't care if volume goes below min
    volume_val=$((volume_val - 2))
elif [[ "$1" == "mute" ]] ; then
    switch_val='off'
elif [[ "$1" == "unmute" ]] ; then
    switch_val='on'
elif [[ "$1" == "toggle" ]] ; then
    if [[ "$switch_val" == 'on' ]] ; then
        switch_val='off'
    elif [[ "$switch_val" == 'off' ]] ; then
        switch_val='on'
    fi
else
    if [[ $quite == 0 ]] ; then
        echo "Usage: $0 {incr|decr|mute|unmute|toggle}"
    fi
    exit 1
fi

update

exit 0
