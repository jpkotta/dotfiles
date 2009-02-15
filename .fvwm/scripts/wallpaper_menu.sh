#!/bin/bash

# converts a whole directory of images into thumbnails
# the thumbnails are stored in a centralized location
# requires helper script wallpaper_convert.sh

# how many images to convert in parallel
concurrency=3

dir="$1";
if [[ ! -d "$dir" ]] ; then
    exit 1;
fi

# where to store the thumbs
if [[ -d "$FVWM_USERDIR" ]] ; then
    thumb_dir="$FVWM_USERDIR/cache/wallpaper_thumbs"
else
    thumb_dir="$HOME/.thumbs"
fi

if [[ ! -d "$thumb_dir/$dir" ]] ; then
    mkdir -p "$thumb_dir/$dir"
fi

# kick off the converter
for (( i = 0 ; i < concurrency ; i++ )) ; do
    # kick off a background converter
    # the >&/dev/null redirect is very important, 
    # as PipeRead will wait for output without it
    (exec $FVWM_USERDIR/scripts/wallpaper_convert.sh -mod $concurrency -plus $i $dir >&/dev/null) &
done

# generate the menu
# this is pretty much independent of the thumbnails
fvwm-menu-directory --dir "$dir" --links --check-subdir --func-name WallpaperBrowser --title "%*-20p" --item '%*20n' \
    --command-title "Exec exec nitrogen $dir" --command-file "SetWallpaper \"%f\"" --command-app "SetWallpaper \"%f\"" \
    --icon-dir mini.folder.xpm --icon-title mini.term.xpm --icon-file __PIXMAP__ --icon-app __PIXMAP__ \
    | sed "s%__PIXMAP__\\(.*\\)\\\"\\(.*/\\)\\(.*\\)\\\"%$thumb_dir/$dir/\\3\\1\\2\\3%g"

echo MenuStyle "$dir"

# clean out old thumbnails if the directory is too big
if [ -x $FVWM_SCRIPTDIR/clean_thumbs.sh ] ; then
    $FVWM_SCRIPTDIR/clean_thumbs.sh $thumb_dir &
fi

exit 0
