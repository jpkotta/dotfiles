echo "Starting X..."
echo
echo "PARAMETERS TO .xinitrc"
echo "$@"
echo "END OF PARAMETERS TO .xinitrc"
echo 

# turn monitors off after 10 min
xset dpms 0 0 600

# set the wallpaper
# do this first because it can take a while
#hsetroot -full $HOME/tmp/current_wallpaper &
nitrogen --restore &

# setup xmodmap, because certain programs (e.g. Mathematica and fvwm) require
# certain settings

# add some special keys
# xmodmap -e "keycode 115 = Super_L"
# xmodmap -e "keycode 116 = Super_R"
# xmodmap -e "keycode 117 = Menu"
# xmodmap -e "add mod4 = Super_L Super_R"

# ain't no good for nothin.
xmodmap -e "remove lock = Caps_Lock"

# volume keys for laptop
if [ x`hostname` = x"goedel" ] ; then
    xmodmap -e "keycode 160 = XF86AudioMute"
    xmodmap -e "keycode 174 = XF86AudioLowerVolume"
    xmodmap -e "keycode 176 = XF86AudioRaiseVolume"
fi 

# make sure my X resources are updated
if [ -r "$HOME/.Xresources" ] ; then
    xrdb -load $HOME/.Xresources
fi

# turn on numlock
[ -x numlockx ] && numlockx

# cd to $HOME, so that all programs started from X start there
cd

disp=`echo $DISPLAY | sed -e 's/://g' -e 's/[.][0-9]*//'`
log_file=$HOME/.X-log-$disp
if [ -e $log_file ] ; then
    mv -f $log_file ${log_file}-old
fi

# load any machine-specific settings
if [ -r $HOME/.xinitrc.local ] ; then
    echo
    echo "Executing machine-specific .xinitrc"
    echo
    . $HOME/.xinitrc.local
    echo
    echo "Finished machine-specific .xinitrc"
    echo
fi

if [ -z "$WM_COMMAND" ] ; then
    WM_COMMAND=fvwm
fi
exec $WM_COMMAND >$HOME/.X-log-${disp} 2>&1

echo 
echo "Shutting Down X..."
echo
