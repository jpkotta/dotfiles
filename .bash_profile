# This is a bash-specific profile script. ~/.profile is not read by
# bash if this file (~/.bash_profile) exists.  See
# /usr/share/doc/bash/examples/startup-files for examples.  The files
# are located in the bash-doc package.

# the default umask is set in /etc/profile
#umask 022

# if running bash
if [ -n "$BASH_VERSION" ]; then
    # include .bashrc if it exists
    if [ -f ~/.bashrc ]; then
        . ~/.bashrc
    fi
fi

# set PATH so it includes user's private bin if it exists
if [ -d ~/bin ] ; then
    PATH=~/bin:"${PATH}"
fi

# keychain manages ssh-agents
type keychain >&/dev/null \
    && keychain

[ -x "$(which fortune)" ] && fortune
