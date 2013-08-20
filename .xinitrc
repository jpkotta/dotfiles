#!/bin/bash

echo
echo "Start system xinitrc"
[ -e /etc/skel/.xinitrc ] && source /etc/skel/.xinitrc
echo "Finish system xinitrc"
echo
echo "Start bash_profile"
[ -e $HOME/.bash_profile ] && source $HOME/.bash_profile
echo "Finish bash_profile"
echo
echo "Start bashrc"
[ -e $HOME/.bashrc ] && source $HOME/.bashrc
echo "Finish bashrc"
echo
echo "Start main .xinitrc"
echo "Parameters to .xinitrc: ""$@"

# cd to $HOME, so that all programs started from X start there
cd

# turn monitors off after 10 min
xset dpms 0 0 600 &

# set the wallpaper
# do this first because it can take a while
nitrogen --restore &

# make caps lock useful
xmodmap -e "remove lock = Caps_Lock"
xmodmap -e "keysym Caps_Lock = BackSpace"

# make sure my X resources are updated
[ -e "$HOME/.Xresources" ] && xrdb -load $HOME/.Xresources

# turn on numlock
numlockx on

# start automounter
udiskie &

# start rxvt-unicode daemon
urxvtd -q -o -f

# load any machine-specific settings
if [ -e "$HOME/.xinitrc.local" ] ; then
    echo
    echo "Start machine-specific .xinitrc"
    . $HOME/.xinitrc.local
    echo "Finish machine-specific .xinitrc"
    echo
fi

# set a default if unset
WM_COMMAND=${WM_COMMAND:=fvwm}
export WM_LOGFILE=$HOME/.window-manager-$DISPLAY.log
[ -e "$WM_LOGFILE" ] && mv -f $WM_LOGFILE ${WM_LOGFILE}.old

echo "Starting window manager: $WM_COMMAND"
exec $WM_COMMAND >& $WM_LOGFILE

echo 
echo "Window manager exit, end of .xinitrc"
echo
