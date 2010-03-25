# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

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

# # set up ssh-agent, if it hasn't been done already
# SSH_AGENT=/usr/bin/ssh-agent
# if [ -z "$SSH_AUTH_SOCK" -a -x "$SSH_AGENT" ] ; then
#     eval $($SSH_AGENT -s)
#     trap "kill $SSH_AGENT_PID" 0
# fi

# keychain manages ssh-agents
which keychain >&/dev/null \
    && keychain

[ -x "$(which fortune)" ] && fortune
