echo "Starting X..."
echo
echo "PARAMETERS TO .xinitrc"
echo "$@"
echo "END OF PARAMETERS TO .xinitrc"
echo 

ubuntu_version=$(lsb_release --release | awk '{ print $2 }')

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
numlockx

# I use this in various scripts
# it's the screen resolution in WxH format, e.g. 1280x960
export SCREEN_RES=`xdpyinfo | grep dimensions | grep -o '[0-9]*x[0-9]*[[:space:]]*pixels' | sed -e 's/pixels//' -e 's/[[:space:]]//'`
export SCREEN_RES_X=`echo $SCREEN_RES | sed -e 's/x.*//'`
export SCREEN_RES_Y=`echo $SCREEN_RES | sed -e 's/.*x//'`

# cd to $HOME, so that all programs started from X start there
cd

disp=`echo $DISPLAY | sed -e 's/://g' -e 's/[.][0-9]*//'`
mv -f $HOME/.X-log-${disp} $HOME/.X-log-${disp}-old

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

#xterm
fvwm >$HOME/.X-log-${disp} 2>&1
#fvwm -f /dev/null >$HOME/.X-log-${disp} 2>&1
#twm >$HOME/.X-log-${disp} 2>&1

echo 
echo "Shutting Down X..."
echo
