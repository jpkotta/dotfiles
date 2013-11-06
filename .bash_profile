# This is a bash-specific profile script. ~/.profile is not read by
# bash if this file (~/.bash_profile) exists.

# include .bashrc if it exists
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# keychain manages ssh-agents
type keychain >&/dev/null \
    && keychain

# a fun message
type fortune >&/dev/null \
    && fortune
