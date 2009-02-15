#!/bin/sh

SCREENSHOT_ICONDIR=/dev/shm
w_id=$1
iconic=$2

if [ x"$w_id" = "xw.id" ] ; then
    exit 0
fi

# get WM_NAME from xprop to avoid quoting complications
# change '*' to '**' because AddToMenu treats '*' as a formatting symbol
name=`xprop -id $w_id WM_NAME | sed -e 's/^WM_NAME(STRING) = //' -e 's/[*]/**/g' -e 's/%/%%/g' | tr "\\042\\140" "\\047\\047"`
len=`echo "${name}" | wc -c`

if [ ${len} -gt 50 ] ; then
    name=`echo "${name}" | cut -c 2-25`"..."`echo "${name}" | cut -c $(( ${len} - 25 ))-$(( ${len} - 2 ))`;
    true
else
    name=`echo "${name}" | cut -c 2-$(( ${len} - 2 ))`;
    true
fi

if [ -z $iconic ] ; then
    echo AddToMenu ScreenShotMenu "'%${SCREENSHOT_ICONDIR}/${w_id}.png%${name}'" WindowId $w_id WindowListFunc
else
    echo AddToMenu ScreenShotMenu "'%${SCREENSHOT_ICONDIR}/${w_id}.png%(${name})'" WindowId $w_id WindowListFunc
fi

