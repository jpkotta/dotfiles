### jpkotta's .bashrc

########################################################################
### notes

# Never start a program from here that will output text.  It screws up
# things like ssh.  Put those in ~/.bash_profile instead.

########################################################################
### things that must be initialized early

# for profiling
function tic()
{
    start_time=`date +%s%N`
}
function toc()
{
    local stop_time
    stop_time=`date +%s%N`
    if [ -n "$1" ] ; then
        echo $1
    fi
    echo "Elapsed time is $(( ($stop_time - $start_time)/1000000 )) ms."
}

# try to make this portable to BSD systems
is_GNU=1
if bash --version | grep -i bsd >&/dev/null; then
    is_GNU=0
fi

########################################################################
### miscellaneous

[ -f /usr/share/bash-completion/bash_completion ] \
    && . /usr/share/bash-completion/bash_completion

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
total_mem=$(grep MemTotal /proc/meminfo | tr -s ' ' | cut -d' ' -f 2)
#ulimit -v $((total_mem*3/4))

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

function pathremove ()
{
    local IFS=':' NEWPATH DIR PATHVARIABLE=${2:-PATH}
    for DIR in ${!PATHVARIABLE} ; do
        if [ "$DIR" != "$1" ] ; then
            NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
        fi
    done
    export $PATHVARIABLE="$NEWPATH"
}

function pathprepend () 
{
    pathremove $1 $2
    local PATHVARIABLE=${2:-PATH}
    export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
}

function pathappend ()
{
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
pathappend /usr/local/lib/python2.6/site-packages PYTHONPATH
pathappend /usr/lib/python2.6/site-packages PYTHONPATH

########################################################################
### application defaults

export EDITOR="$HOME/bin/editor"
export PAGER="less"
export DE=kde # workaround for xdg-open

########################################################################
### prompt

# color escape codes
normal="\[\e[0m\]"
nobg="m\]"
blackbg=";40m\]"
redbg=";41m\]"
greenbg=";42m\]"
brownbg=";43m\]"
bluebg=";44m\]"
magentabg=";45m\]"
cyanbg=";46m\]"
greybg=";47m\]"
black="\[\e[0;30$nobg"
redfaint="\[\e[0;31$nobg"
greenfaint="\[\e[0;32$nobg"
brownfaint="\[\e[0;33$nobg"
bluefaint="\[\e[0;34$nobg"
magentafaint="\[\e[0;35$nobg"
cyanfaint="\[\e[0;36$nobg"
greyfaint="\[\e[0;37$nobg"
grey="\[\e[1;30$nobg"
red="\[\e[1;31$nobg"
green="\[\e[1;32$nobg"
yellow="\[\e[1;33$nobg"
blue="\[\e[1;34$nobg"
magenta="\[\e[1;35$nobg"
cyan="\[\e[1;36$nobg"
white="\[\e[1;37$nobg"
bold="\[\e[1$nobg"

# prompt pieces
prompt_open="$blue[$normal"
prompt_close="$blue]$normal"
prompt_close_open="$prompt_close$prompt_open"
prompt_username="$cyan\u$normal"
[ $UID = 0 ] && prompt_username="$red\u$normal"
prompt_at="$blue@$normal"
prompt_hostname="$cyan\h$normal"
prompt_jobs="$cyan\j$normal"
prompt_time="$cyan\t$normal"
prompt_pwd="$magenta\w$normal"
prompt_cmd_num="$blue\#$normal"
prompt_err_stat="\
\`__lasterr=\$?; \
if [ \$__lasterr = 0 ] ; then \
echo -ne '$cyan' ; \
else echo -ne '$red' ; \
fi ; \
echo \$__lasterr ; \
exit $__lasterr\`$normal"
# prompt_err_stat="$cyan\`echo \$?\`$normal"
prompt_prompt="$blue\\\$$normal"
prompt_dpy="$cyan\$DISPLAY$normal"

PLAIN_PROMPT='[\u@\h][\w](\j)\n\$ '
FANCY_PROMPT="\
$prompt_open$prompt_time$prompt_close_open\
$prompt_username$prompt_at$prompt_hostname$prompt_close_open\
$prompt_pwd$prompt_close_open\
$prompt_jobs$prompt_close_open\
$prompt_err_stat$prompt_close_open\
$prompt_dpy$prompt_close\
\n$prompt_prompt "

export PS1=$FANCY_PROMPT
if [[ $TERM == '' ]] ; then
    export PS1=$PLAIN_PROMPT
fi

unset prompt_open prompt_close prompt_close_open prompt_username \
    prompt_at prompt_hostname prompt_jobs prompt_time prompt_pwd \
    prompt_cmd_num prompt_err_stat prompt_prompt prompt_dpy

# this sets the title of the terminal window:
# 'user@host: /present/working/directory/ [ previous_command args ]'
# see the Eterm technical docs, "Set X Terminal Parameters"
# 'ESC ] 0 ; string BEL' sets icon name and title to string
# seems to not work when there is a space before \007
function set_terminal_title()
{
    echo -ne "\033]0;$1\007"
}

# package maintainers don't understand how to keep termcaps up to date
if [[ "$TERM" == 'rxvt-unicode' ]] ; then
    TERM=rxvt
fi

if [[ "$TERM" =~ "rxvt" \
    || "$TERM" =~ "xterm" \
    || "$TERM" =~ "screen" ]] ; then
    PROMPT_COMMAND='set_terminal_title "[${USER}@${HOSTNAME}][${PWD/$HOME/~}] "'
else
    PROMPT_COMMAND=
fi

if [[ "$TERM" = "screen" ]] ; then
    DYNAMIC_TITLE="\[\033k\w\033\134\]"

    function set_dynamic_screen_title ()
    {
        if [ "$1" -ne 0 ] ; then 
            PS1=$DYNAMIC_TITLE$FANCY_PROMPT
        else
            PS1=$FANCY_PROMPT
        fi
    }

    set_dynamic_screen_title 1
fi

########################################################################
### miscellaneous environment variables

# optimizations
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse'
# more dangerous flags
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse,387'

# some programs' startup scipts need to know the screen res
if xdpyinfo >& /dev/null ; then
    export DPY_RES=`xdpyinfo | grep dimensions | awk '{ print $2 }'`
    dpy_res_x=`echo $DPY_RES | sed s/x.*//`
    dpy_res_y=`echo $DPY_RES | sed s/.*x//`
    if [ $dpy_res_x -ge $(( $dpy_res_y*2 )) ] ; then
        # assume that if the x res is that much bigger, we have dual screen
        scr_res_x=$(($dpy_res_x / 2))
    else
        scr_res_x=$dpy_res_x
    fi
    export SCR_RES=${scr_res_x}x${dpy_res_y}
    unset scr_res_x scr_res_y dpy_res_x dpy_res_y
fi

########################################################################
### colors

# set up colors for ls
if [ $is_GNU = 0 ] ; then
    DIRCOLORS=gdircolors
else
    DIRCOLORS=dircolors
fi
if type $DIRCOLORS >&/dev/null ; then
    if [ ! -e $HOME/.dircolors ] ; then
        $DIRCOLORS --print-database > $HOME/.dircolors
    fi
    eval `$DIRCOLORS --sh $HOME/.dircolors`
fi

export GREP_COLORS="ms=01;32:mc=01;32:sl=:cx=:fn=35:ln=32:bn=32:se=36"

function showcolors()
{
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
function daemon
{
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

if ! type realpath >&/dev/null ; then
    alias realpath='readlink -f'
fi

if [ $TERM != "dumb" ] ; then
    BASHRC=`realpath $BASH_SOURCE`
    # source this file
    alias jpk="source $BASHRC"
    # edit this file
    alias aka='$EDITOR $BASHRC'
fi

# handy notes file
alias note='$EDITOR $HOME/doc/notes.txt'

# common typo, easier to type
alias cd..='cd ..'
function cd_up()
{
    # do 'cd ..' N times
    local x i d
    if [ -z "$1" ] ; then 
        return
    fi
    x=$(($1 * ($1 > 0))) # positive or zero

    d=""
    for i in `seq 1 $x` ; do
        d=$d"../"
    done
    cd $d
}
alias ..='cd_up 1'
alias ...='cd_up 2'
alias ....='cd_up 3'
alias .....='cd_up 4'
alias ......='cd_up 5'
# go to the previous pwd
alias prev='cd -'
# cd to the "work directory"
alias cdw="cd $HOME/w"
# cd to the source directory
alias cds="cd $HOME/src"
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
function psk() { kill `psg "$@" | awk '{print $1}'` ; }
function psK() { kill -KILL `psg "$@" | awk '{print $1}'` ; }
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
if [ $is_GNU = 0 ] ; then
    LS=gls
else
    LS=ls
fi

if $LS -vF --color=auto >&/dev/null ; then
    alias ls="$LS -vF --color=auto"
else
    alias ls="$LS -F"
fi
alias l='ls'
# long listing
alias ll='ls -l'
# list all files
alias la='ls -A'
# list only hidden files
alias lh='ls -A -I "[^.]*"'
# long listing, sort by mod date
alias lt='ls -lt'
# long list of all files
alias lla='ls -lA'
# display only directories
function lsdir()
{
    local i
    for i in "$@" ; do
    if [ -d "$i" ] ; then
        (
        cd "$i"
        ls --color=auto -v -d */
        )
    fi
    done
}
alias lsd='lsdir'
# display 'canonical' name (guaranteed to be unique and not a symlink)
alias lc='realpath'
# display canonical name of an executable in the path
function le()
{
    realpath `which $1`
}

# clear the screen, Ctrl-L also works
alias cls='clear'
alias clc='clear'
# use symlinks only, treat links to dirs as normal files, interactive
alias ln='/bin/ln -sni'

# a kinder, safer rm
# if type trash-put >&/dev/null ; then
#     alias rm="trash-put"
# else
#     alias rm="rm -I"
# fi
alias rm="rm -I"
function rm-rf()
{
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
# remove all data from file, or create an empty file
alias empty='/bin/cp /dev/null'
# safer mv
alias mv='mv -i'
# swiss army chainsaw of file naming
alias ren="perl-rename"
# safer cp
alias cp='cp -i'
# creates parent dirs if they do not exist
alias mkdir='mkdir -p'
# deletes empty directory tree
alias rmdir='rmdir -p'
# rsync for updating usb drives
alias rsync='rsync -auv'
# use additional locate databases
alias locate_on_network='LOCATE_PATH=$_LOCATE_PATH locate'
# password generator
alias apg="apg -M sNCL"

####################################
# less is more

export LESS="--LONG-PROMPT --RAW-CONTROL-CHARS"

# configure less to page just about anything in a rational way
if type lessfile >&/dev/null ; then
    eval $(lessfile)
fi

# _v_iewer
function v()
{
    if [ -d "$1" ] ; then
        if type tree >&/dev/null ; then
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

# sdiff the way it was at IBM
alias sdiff='/usr/bin/sdiff --expand-tabs --ignore-all-space --strip-trailing-cr --width=160'
function dif()
{
    if type colordiff >&/dev/null ; then
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
# ping the way it was at IBM, but better
# -c 5 means send five packets, time out after 5 sec
# -A means adapt interval so as to be fast as possible with only one packet in transit at a time
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
alias rdp="rdesktop -x lan -K -g $SCR_RES"
# fusermount
alias fumount='fusermount -u -z'

# tight vncviewer options for internet connections
alias vncremote="vncviewer -encoding 'tight copyrect corre hextile' -quality 8 -compresslevel 6 -bgr233 -geometry $SCR_RES"

########################################################################
### functions

function mpumount()
{
    for i in $@ ; do
        pumount $i
    done
}

# rsync with delete and confirmation
function synchronize()
{
    local PS3 cmd name
    name="synchronize"
    PS3="Pick a number: "
    cmd="rsync --archive --update --verbose --delete --protect-args"

    if [ -z "$2" ] ; then
        echo "Usage: $name <source> <destination>"
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

# creates a dated tarball
function tarball()
{
    local name
    name=$1
    shift
    tar zcf $name-`date +%Y%m%d`.tar.gz "$@"
}

function spell()
{
    local word resp

    if ! type ispell >/dev/null ; then
        echo "This requires ispell."
        echo "Install it with 'sudo aptitude install ispell'"
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
            
            resp=$(echo $word | ispell -a -m -B | grep -v "^[@*+-]")
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

function define()
{
    # dict is in the dict package
    dict $@ | less
}

function wiki()
{
    if [ -z "$1" ] ; then
        echo "Usage: $0 article name"
        echo "Print the beginning of Wikipedia article."
        return
    fi
    dig +short txt "$*".wp.dg.cx;
}

########################################################################
### source other rc files

if [ -e $HOME/.bashrc.local ] ; then
    source $HOME/.bashrc.local
fi

for i in $HOME/.bash.d/* ; do
    if [ -r "$i" ] ; then
        source "$i"
    fi
done
unset i
