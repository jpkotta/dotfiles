#!/bin/bash

[ -e $HOME/.bash_profile ] && . $HOME/.bash_profile
[ -e $HOME/.bashrc ] && . $HOME/.bashrc

echo "Running .xinitrc"
echo "Parameters to .xinitrc: ""$@"

# cd to $HOME, so that all programs started from X start there
cd

# turn monitors off after 10 min
xset dpms 0 0 600 &

# set the wallpaper
# do this first because it can take a while
nitrogen --restore &

# add some special keys
# xmodmap -e "keycode 115 = Super_L"
# xmodmap -e "keycode 116 = Super_R"
# xmodmap -e "keycode 117 = Menu"
# xmodmap -e "add mod4 = Super_L Super_R"

# make caps lock useful
xmodmap -e "remove lock = Caps_Lock"
#xmodmap -e "add control = Caps_Lock"
xmodmap -e "keysym Caps_Lock = BackSpace"

# volume keys for laptop
if [ x`hostname` = x"goedel" ] ; then
    xmodmap -e "keycode 160 = XF86AudioMute"
    xmodmap -e "keycode 174 = XF86AudioLowerVolume"
    xmodmap -e "keycode 176 = XF86AudioRaiseVolume"
fi 

# make sure my X resources are updated
[ -e "$HOME/.Xresources" ] \
    && xrdb -load $HOME/.Xresources

# turn on numlock
numlockx on

# start automounter
udiskie &

# start rxvt-unicode daemon
urxvtd -q -o -f

disp=`echo $DISPLAY | sed -e 's/://g' -e 's/[.][0-9]*//'`
log_file=$HOME/.X-log-$disp
[ -e "$log_file" ] \
    && mv -f $log_file ${log_file}-old

# load any machine-specific settings
if [ -e "$HOME/.xinitrc.local" ] ; then
    echo
    echo "Executing machine-specific .xinitrc"
    echo
    . $HOME/.xinitrc.local
    echo
    echo "Finished machine-specific .xinitrc"
    echo
fi

# set a default if unset
WM_COMMAND=${WM_COMMAND:=fvwm}

echo "Starting window manager: $WM_COMMAND"
exec $WM_COMMAND >$log_file 2>&1

echo 
echo "Window manager exit, end of .xinitrc"
echo
