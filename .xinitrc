#!/bin/bash

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# merge in defaults and keymaps

if [ -f $sysresources ]; then
    xrdb -merge $sysresources
fi

if [ -f $sysmodmap ]; then
    xmodmap $sysmodmap
fi

if [ -f "$userresources" ]; then
    xrdb -merge "$userresources"
fi

if [ -f "$usermodmap" ]; then
    xmodmap "$usermodmap"
fi

# start some nice programs

if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

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

# these could be started with systemd, but it's really flaky
(exec /usr/lib/notification-daemon-1.0/notification-daemon &)
#(exec xset dpms 0 0 600 &)
(exec nitrogen --restore &)
(exec numlockx on &)
(exec xscreensaver -no-splash &)

# load any machine-specific settings
xinitrc_local=$HOME/.xinitrc.local
if [ -f $xinitrc_local ] ; then
    source $xinitrc_local
fi

# set a default if unset
WM_COMMAND=${WM_COMMAND:=fvwm}
#WM_COMMAND=awesome
export WM_LOGFILE=$HOME/.cache/window-manager-$DISPLAY.log
[ -e "$WM_LOGFILE" ] && mv -f $WM_LOGFILE ${WM_LOGFILE}.old

echo "Starting window manager: $WM_COMMAND"
exec $WM_COMMAND >& $WM_LOGFILE

echo
echo "Window manager exit, end of .xinitrc"
echo
