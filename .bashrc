### jpkotta's .bashrc

########################################################################
### notes

# Never start a program from here that will output text.  It screws up
# things like ssh.  Put those in ~/.bash_profile instead.

# Scripts (but not interactive shells) should use strict mode:
#   set -o errexit -o nounset -o pipefail
#   IFS=$'\n\t'

########################################################################
### things that must be initialized early

# try to make this portable to BSD systems
is_GNU=true
if bash --version | grep -i bsd >&/dev/null; then
    is_GNU=false
fi

function is_command() {
    type $1 >&/dev/null
}

########################################################################
### miscellaneous

function set_up_completion() {
    local i
    for i in /usr/share/bash-completion/bash_completion /etc/bash_completion ; do
        [ -f $i ] && . $i
    done
}
set_up_completion

# this causes output from background processes to be output right away,
# rather than waiting for the next primary prompt
set -o notify

# No history expansion.  I never use it and it causes ! to be treated
# strangely.
set +o histexpand

# set the default file permissions
# the default permissions are 777 for dirs, 666 for files
# the actual permission is given by (default & ~umask)
# e.g. for umask = 0022, file = 644, dir = 755
umask 0022

# allow core files to be dumped
#ulimit -c hard

# Prevent rogue processes from using all the ram.  -v is the only
# memory limit that actually works on Linux.
function set_up_mem_limit() {
    local total_mem=$(grep MemTotal /proc/meminfo | tr -s ' ' | cut -d' ' -f 2)
    ulimit -v $((total_mem*3/4))
}
#set_up_mem_limit

# this stops C-s from freezing the terminal
if [ "$TERM" != "dumb" ] && ! shopt -q login_shell ; then
    # FIXME for some reason, this just started hanging during xinit
    stty -ixon
fi

# prevent C-d from immediately logging out
export IGNOREEOF=1

# this is set but not exported by default
export HOSTNAME

# keychain keeps track of ssh-agents
[ -f $HOME/.keychain/$HOSTNAME-sh ] \
    && . $HOME/.keychain/$HOSTNAME-sh

# append to .bash_history instead of overwriting
shopt -s histappend
HISTFILESIZE=5000

export EMAIL="jpkotta@gmail.com"

########################################################################
### path variables

# these functions allow us to set the PATH idempotently

function pathremove () {
    local IFS=':' NEWPATH DIR PATHVARIABLE=${2:-PATH}
    for DIR in ${!PATHVARIABLE} ; do
        if [ "$DIR" != "$1" ] ; then
            NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
        fi
    done
    export $PATHVARIABLE="$NEWPATH"
}

function pathprepend () {
    pathremove $1 $2
    local PATHVARIABLE=${2:-PATH}
    export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

function pathappend () {
    pathremove $1 $2
    local PATHVARIABLE=${2:-PATH}
    export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
}

[ -z "$PATH" ] && PATH=/bin:/usr/bin
for d in /sbin /usr/sbin /usr/local/bin /usr/local/sbin \
    /usr/X11R6/bin /usr/games /usr/local/games /usr/share/games/bin ; do
    pathappend $d PATH
done
for d in $HOME/usr/local/bin $HOME/bin ; do
    pathprepend $d PATH
done
unset d

#pathappend /usr/local/lib LD_LIBRARY_PATH
pathappend /usr/local/include C_INCLUDE_PATH
pathappend /usr/local/include CPLUS_INCLUDE_PATH
pathappend /usr/local/lib LIBRARY_PATH
pathappend /usr/lib/pkgconfig PKG_CONFIG_PATH

########################################################################
### application defaults

export EDITOR="$HOME/bin/editor"
export PAGER="less"
export DE=kde # workaround for xdg-open

########################################################################
### prompt

function set_up_prompt() {
    PROMPT_DIRTRIM=3
    
    if [[ "$TERM" == '' ]] ; then
        PS1='[\u@\h][\w](\j)\n\$ '
        return
    fi

    # color escape codes
    local normal="\[\e[0m\]"
    local nobg="m\]"
    local blackbg=";40m\]"
    local redbg=";41m\]"
    local greenbg=";42m\]"
    local brownbg=";43m\]"
    local bluebg=";44m\]"
    local magentabg=";45m\]"
    local cyanbg=";46m\]"
    local greybg=";47m\]"
    local black="\[\e[0;30$nobg"
    local redfaint="\[\e[0;31$nobg"
    local greenfaint="\[\e[0;32$nobg"
    local brownfaint="\[\e[0;33$nobg"
    local bluefaint="\[\e[0;34$nobg"
    local magentafaint="\[\e[0;35$nobg"
    local cyanfaint="\[\e[0;36$nobg"
    local greyfaint="\[\e[0;37$nobg"
    local grey="\[\e[1;30$nobg"
    local red="\[\e[1;31$nobg"
    local green="\[\e[1;32$nobg"
    local yellow="\[\e[1;33$nobg"
    local blue="\[\e[1;34$nobg"
    local magenta="\[\e[1;35$nobg"
    local cyan="\[\e[1;36$nobg"
    local white="\[\e[1;37$nobg"
    local bold="\[\e[1$nobg"

    # prompt pieces
    local op="$blue[$normal"
    local cl="$blue]$normal"
    local clop="$blue][$normal"
    local username="$cyan\u$normal"
    [ $UID = 0 ] && username="$red\u$normal"
    local at="$blue@$normal"
    local hostname="$cyan\h$normal"
    local jobs="${cyan}J\j$normal"
    local time="$cyan\t$normal"
    local pwd="$magenta\w$normal"
    local cmd_num="$blue\#$normal"
    local err_stat="\
\`__lasterr=\$?; \
if [ \$__lasterr = 0 ] ; then \
echo -ne '$cyan' ; \
else echo -ne '$red' ; \
fi ; \
echo E\$__lasterr ; \
exit $__lasterr\`$normal"
    local prompt="$blue\\\$$normal"
    local dpy="${cyan}D\$DISPLAY$normal"

    PS1="$op$time$clop$username$at$hostname$clop$pwd$clop$jobs$clop$err_stat$clop$dpy$cl\n$prompt "
}
set_up_prompt

# this sets the title of the terminal window:
# 'user@host: /present/working/directory/ [ previous_command args ]'
# see the Eterm technical docs, "Set X Terminal Parameters"
# 'ESC ] 0 ; string BEL' sets icon name and title to string
# seems to not work when there is a space before \007
function set_terminal_title() {
    echo -ne "\033]0;$1\007"
}

# package maintainers don't understand how to keep termcaps up to date
if [[ "$TERM" == 'rxvt-unicode' ]] ; then
    TERM=rxvt
fi

if [[ "$TERM" =~ "rxvt" || "$TERM" =~ "xterm" || "$TERM" =~ "screen" ]] ; then
    PROMPT_COMMAND='set_terminal_title "[${USER}@${HOSTNAME}][${PWD/$HOME/~}] "'
else
    PROMPT_COMMAND=
fi

########################################################################
### colors

# set up colors for ls
function set_up_dircolors() {
    local dircolors=dircolors
    if ! $is_GNU ; then
        dircolors=gdircolors
    fi

    if is_command $dircolors ; then
        if [ ! -e $HOME/.dircolors ] ; then
            $dircolors --print-database > $HOME/.dircolors
        fi
        
        eval $($dircolors --sh $HOME/.dircolors)
    fi
}
set_up_dircolors

export GREP_COLORS="ms=01;32:mc=01;32:sl=:cx=:fn=35:ln=32:bn=32:se=36"

function showcolors() {
    local esc="\033[" fore line1 line2
    echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
    for fore in 30 31 32 33 34 35 36 37; do
        line1="$fore  "
        line2="    "
        for back in 40 41 42 43 44 45 46 47; do
            line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
            line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
        done
        echo -e "$line1\n$line2"
    done

    echo ""
    echo "# Example:"
    echo "#"
    echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
    echo "#"
    echo "#           ESC"
    echo "#            |  CD"
    echo "#            |  | CD2"
    echo "#            |  | | FG"
    echo "#            |  | | |  BG + m"
    echo "#            |  | | |  |         END-CD"
    echo "#            |  | | |  |            |"
    echo "# echo -e '\033[1;5;33;44mTJEENARE\033[0m'"
    echo "#"
}

########################################################################
### aliases

# super stealth background launch
# disconnects from launching shell, keeps running until killed
function daemon {
    (exec "$@" >&/dev/null &)
}

alias d=daemon

# default editor
alias E="daemon $EDITOR"
alias EE="$EDITOR"

# terminal
alias T="daemon terminal"

# browser
alias B="daemon browser"

function session() {
    if [ -z "$1" ] ; then
        echo "Usage: $FUNCNAME session-name [command]"
        return
    fi
    local socket=$1
    shift
    if [ -z "$1" ] ; then
        dtach -A /tmp/$socket -z bash
    else
        dtach -A /tmp/$socket -z "$@"
    fi
}

alias S="session"

if ! is_command realpath ; then
    alias realpath='readlink -f'
fi

function cd_up() {
    # do 'cd ..' N times
    local x i d
    if [ -z "$1" ] ; then 
        return
    fi
    x=$(($1 * ($1 > 0))) # positive or zero

    d=""
    for i in $(seq 1 $x) ; do
        d=$d"../"
    done
    cd $d
}
alias ..='cd_up 1'
alias ...='cd_up 2'
alias ....='cd_up 3'
alias .....='cd_up 4'
alias ......='cd_up 5'
alias cd..='cd ..'
alias prev='cd -' # go to the previous pwd
alias cdw="cd $HOME/w" # cd to the "work directory"
alias cds="cd $HOME/src" # cd to the source directory
# mkdir and cd to it
function cdmk() { mkdir -p "$1" ; cd "$1" ; }

# move around dirstack more easily
function cd() {
    local num_dirs 
    
    if [ -z "$1" ] ; then
        if [ "$PWD" != "$HOME" ] ; then
            builtin pushd "$HOME" >/dev/null
        fi
        return
    fi

    num_dirs=${#DIRSTACK[@]}

    case $1 in
        "-") builtin cd - && pushd -n "$PWD" >/dev/null ;;
        "_") [ $num_dirs -gt 1 ] && builtin popd >/dev/null || true ;;
        *) builtin pushd "$1" >/dev/null ;;
    esac
}

# list of processes matching a regex
# ps[kK] should be modified to use pkill/pgrep
alias psg="ps -e -o pid,ppid,user,%cpu,%mem,start_time,cmd \
| grep -vE 'grep|ps[gkK]' | grep -E"
function psk() { kill $(psg "$@" | awk '{print $1}') ; }
function psK() { kill -KILL $(psg "$@" | awk '{print $1}') ; }
# like psg, but shows different info
alias psgaux='ps auxw | grep -vE "grep|psg" | grep -E'

# kill emacs server in a controlled way
alias kill_emacs_server="emacsclient -e '(client-save-kill-emacs)'"

# grep
alias grep='grep --color=auto'
# see also ack-grep
alias srcgrp="grep -RE --include='*.[ch]' --include='*.cpp' -n"

# ls aliases
# workaround for BSD
function set_up_ls_aliases() {
    local ls_prog=ls
    if ! $is_GNU ; then
        ls_prog=gls
    fi

    if $ls_prog -vF --color=auto >&/dev/null ; then
        alias ls="$ls_prog -vF --color=auto"
    else
        alias ls="$ls_prog -F"
    fi
    
    alias l='ls' # simple
    alias ll='ls -l' # long listing
    alias la='ls -A' # list all files

    alias lh='ls -A -I "[^.]*"' # list only hidden files
    alias lt='ls -lt' # long listing, sort by mod date
    alias lla='ls -lA' # long list of all files

    # display 'canonical' name (guaranteed to be unique and not a symlink)
    alias lc='realpath'
    
    # display canonical name of an executable in the path
    function le() {
        realpath $(which $1)
    }
}
set_up_ls_aliases

alias ln='/bin/ln -ni' # treat links to dirs as normal files, interactive

# a kinder, safer rm
# if is_command trash-put ; then
#     alias rm="trash-put"
# else
#     alias rm="rm -I"
# fi
alias rm="rm -I"
function rm-rf() {
    echo "Delete these files?"
    ls -dFv --color=auto "$@"
    PS3="Please enter a number: "
    local resp
    select resp in y n ; do
        if [ "$resp" = "y" ] ; then
            /bin/rm -rf "$@"
            break
        elif [ "$resp" = "n" ] ; then
            echo "Cancel."
            break
        else
            echo "Invalid choice."
        fi
    done
}
# deletes backup files
alias rmbck='/bin/rm -f ./*.bck ./.*.bck ./*?~ ./.*?~'

alias mv='mv -i'
alias ren="perl-rename" # swiss army chainsaw of file naming
alias cp='cp -i'
alias mkdir='mkdir -p'
alias rmdir='rmdir -p'

# use additional locate databases
alias locate_on_network='LOCATE_PATH=$_LOCATE_PATH locate'

alias apg="apg -M sNCL" # password generator

####################################
# less is more

export LESS="--LONG-PROMPT --RAW-CONTROL-CHARS"

# configure less to page just about anything in a rational way
if is_command lessfile ; then
    eval $(lessfile)
fi

# viewer
function v() {
    if [ -d "$1" ] ; then
        if is_command tree ; then
            tree -C "$@" | less -r --LONG-PROMPT
        else
            ls -R --color=always | less -r --LONG-PROMPT
        fi
    else
        less --LONG-PROMPT "$@"
    fi
}

# this is another way to open just about any file the right way
alias open="daemon xdg-open"

alias sdiff='/usr/bin/sdiff --expand-tabs --ignore-all-space --strip-trailing-cr --width=160'
function dif() {
    if is_command colordiff ; then
        colordiff -u "$@"
    else
        diff -u "$@"
    fi
}

# displays global disk usage by partition, excluding supermounted devices
alias df='df -h -x supermount'
# displays disk usage by directory, in human readable format
alias du='du -h'
# du on files and dirs in pwd, sorted by size
alias dusrt="du --max-depth=1 --all --one-file-system 2>/dev/null | sort -h"

# display the processes that are using the most CPU time and memory
alias hogc="ps -e -o %cpu,pid,ppid,user,cmd | sort -nr | head"
alias hogm="ps -e -o %mem,pid,ppid,user,cmd | sort -nr | head"

alias ping='ping -c 5 -A'

# screenshot
alias screenshot="xwd -root -silent | convert xwd:- png:$HOME/screenshot.png"
# image viewer
alias gq="geeqie"
# password database
alias kp="keepassx $HOME/.keepassx/keepass.kdb"

# xine media player
alias xine="daemon xine --enqueue"
# remote desktop
alias rdp="rdesktop -x lan -K -g 1280x1024"
# fusermount
alias fumount='fusermount -u -z'

# tight vncviewer options for internet connections
alias vncremote="vncviewer -encoding 'tight copyrect corre hextile' -quality 8 -compresslevel 6 -bgr233 -geometry $SCR_RES"

########################################################################
### functions

function gitaur() {
    # Don't forget to `ssh-add ~/.ssh/id_aur`.
    read -p "Cloning '$1' into /tmp. (press enter)"
    cd /tmp/
    git clone ssh://aur@aur.archlinux.org/$1.git
    [ -d $1 ] && cd $1
}

function mpumount() {
    local i
    for i in $@ ; do
        pumount $i
    done
}

# rsync with delete and confirmation
function synchronize() {
    local PS3 cmd
    PS3="Pick a number: "
    cmd="rsync --archive --update --verbose --delete --protect-args --one-file-system"

    if [ -z "$2" ] ; then
        echo "Usage: $FUNCNAME <source> <destination>"
        echo "Uses rsync to synchronize destination with source."
        echo "Shows you what will happen before doing anything."
        return 1
    fi

    $cmd --dry-run "$@" | $PAGER
    select resp in yes no ; do
        if [[ "$resp" = yes ]] ; then
            $cmd "$@"
            return $?
        elif [[ "$resp" = no ]] ; then
            return 1
        fi
    done
}

function spell() {
    local word resp

    is_command aspell && cmd=aspell
    if [ -z "$cmd" ] ; then
        is_command ispell && cmd=ispell
    fi
    if [ -z "$cmd" ] ; then
        echo "This requires aspell or ispell."
        return 1
    fi
    
    if [ -z "$1" ]; then
        echo "Usage: spell word1 [ word2 ... ]"
        return 1
    else
        while [ -n "$1" ] ; do
            word=$1
            shift

            # from ispell man page:
            # OK:    *
            # Root:  + <root>
            # Compound:
            #        -
            # Miss:  & <original> <count> <offset>: <miss>, <miss>, ..., <guess>, ...
            # Guess: ? <original> 0 <offset>: <guess>, <guess>, ...
            # None:  # <original> <offset>
            
            resp=$(echo $word | $cmd -a -m -B | grep -v "^[@*+-]")
            if [ -z "$resp" ] ; then
                # example:
                # $ echo spell | ispell -a -m -B
                # @(#) International Ispell Version 3.1.20 10/10/95, patch 1
                # *
                #
                # example:
                # $ echo spelled | ispell -a -m -B
                # @(#) International Ispell Version 3.1.20 10/10/95
                # + SPELL
                echo "'$word' is spelled correctly."
            else
                # example with suggestions:
                # $ echo spel | ispell -a -m -B
                # @(#) International Ispell Version 3.1.20 10/10/95, patch 1
                # & spel 7 0: Opel, spec, sped, spell, spelt, spew, spiel
                #
                # example with no suggestions:
                # $ echo asdf | ispell -a -m -B                                              
                # @(#) International Ispell Version 3.1.20 10/10/95
                # # asdf 0
                resp=$(echo $resp | grep '^&' | sed -e 's/&.*://')
                if [ -z "$resp" ] ; then
                    resp=" <NONE>"
                fi
                echo "Suggestions for '$word':$resp"
            fi
        done
    fi
}

function define() {
    # dict is in the dict package
    dict $@ | less
}

function wiki() {
    if [ -z "$1" ] ; then
        echo "Usage: $FUNCNAME article name"
        echo "Print the beginning of Wikipedia article."
        return
    fi
    dig +short txt "$*".wp.dg.cx;
}

########################################################################
### source other rc files

function source_local_bash_files() {
    [ -e $HOME/.bashrc.local ] && \
        source $HOME/.bashrc.local

    local i
    for i in $HOME/.bash.d/* ; do
        if [ -r "$i" ] ; then
            source "$i"
        fi
    done
}
source_local_bash_files
