#!/bin/bash

# forces recreation of thumbs, for debugging
recreate=0

# which extensions a convert is attempted on
# this is actually a grep regex
extensions="jpg|jpeg|png|gif|tif|tga"

while true ; do 
    if [[ "$1" == "-mod" ]] ; then
        mod="$2";
        shift 2;
    elif [[ "$1" == "-plus" ]] ; then
        offset="$2";
        shift 2;
    else
        dir="$1";
        break;
    fi
done

if [[ ! -d "$dir" ]] ; then
    exit 1;
fi

# where to store the thumbs
if [[ -d "$FVWM_USERDIR" ]] ; then
    thumb_dir="$FVWM_USERDIR/cache/wallpaper_thumbs"
else
    thumb_dir="$HOME/.thumbs"
fi

cd $dir
count=0;
for file in * ; do
    if [[ $(( ($count % $mod) - $offset )) != 0 ]] ; then
        count=$((count + 1));
        continue;
    else
        count=$((count + 1));
    fi

    orig="$dir/$file"
    if [[ -d "$orig" ]] ; then
        continue;
    fi

    thumb="$thumb_dir/$dir/$file"
    if [[ -e "$thumb" ]] ; then
        continue;
    fi

    if true ; then # debug
    #if [[ "$orig" -nt "$thumb" ]] ; then
        # only try to convert files with the specified extensions
        if [[ -n `echo "$orig" | grep -iE "\.($extensions)$"` ]] ; then
            # big
            convert -size 128x96 -thumbnail '126x94>' \
                -bordercolor transparent -border 64 \
                -gravity center -crop 128x96+0+0 \
                "$orig" png:"$thumb" >&/dev/null
#             # small
#             convert -size 64x48 -thumbnail '62x46>' \
#                 -bordercolor transparent -border 32 \
#                 -gravity center -crop 64x48+0+0 \
#                 "$orig" png:"$thumb" >&/dev/null
        fi
    fi
done

