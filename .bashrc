# JPK's .bashrc

########################################################################
# NOTES

# Never start a program from here that will output text.  It screws up
# things like ssh.  Put those in ~/.bash_profile instead.

########################################################################

# for profiling
function tic()
{
    start_time=`date +%s%N`
}
function toc()
{
    stop_time=`date +%s%N`
    if [ -n "$1" ] ; then
        echo $1
    fi
    echo "Elapsed time is $(( ($stop_time - $start_time)/1000000 )) ms."
}

# try to make this portable to BSD systems
is_GNU=1
if bash --version | grep -iq bsd ; then
    is_GNU=0
fi

########################################################################

# bash_completion has an error, that causes it to fail if you source
# it more than once, thus we make it idempotent
if [ -z "$BASH_COMPLETION" ] ; then
    [ -f /etc/bash_completion ] \
        && . /etc/bash_completion
fi

# autojump is a complement for cd
# https://github.com/joelthelion/autojump
[ -f /etc/profile.d/autojump.bash ] && . /etc/profile.d/autojump.bash

# ubuntu wraps this around every command, and more often than not it's
# just annoying
unset command_not_found_handle

# this causes output from background processes to be output right away,
# rather than waiting for the next primary prompt
set -b

# set the default file permissions
# the default permissions are 777 for dirs, 666 for files
# the actual permission is given by (default & ~umask)
# e.g. for umask = 0022, file = 644, dir = 755
umask 0022

# this stops crtl-s from freezing the terminal
if [ "$TERM" != "dumb" ] ; then
    stty -ixon
fi

# prevent CTRL-D from immediately logging out
export IGNOREEOF=1

########################################################################
# source other rc files

if [ -e ~/.bashrc.local ] ; then
    source ~/.bashrc.local
fi

for i in ~/.bash.d/* ; do
    if [ -r "$i" ] ; then
        source "$i"
    fi
done

# keychain keeps track of ssh-agents
[ -f $HOME/.keychain/$HOSTNAME-sh ] \
    && . $HOME/.keychain/$HOSTNAME-sh

########################################################################
# PATH VARIABLES

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
    /usr/X11R6/bin /usr/games /usr/local/games /usr/share/games/bin . ; do
    pathappend $d PATH
done
for d in $HOME/usr/local/bin $HOME/bin ; do
    pathprepend $d PATH
done
    
#pathappend /usr/local/lib LD_LIBRARY_PATH
pathappend /usr/local/include C_INCLUDE_PATH
pathappend /usr/local/include CPLUS_INCLUDE_PATH
pathappend /usr/local/lib LIBRARY_PATH
pathappend /usr/lib/pkgconfig PKG_CONFIG_PATH
pathappend /usr/local/lib/python2.6/site-packages PYTHONPATH
pathappend /usr/lib/python2.6/site-packages PYTHONPATH

########################################################################
# DEFAULT APPS

export EDITOR="emacsclient -c -a ''"
export BROWSER="opera -newwindow"
export PAGER="less"
export PDF_READER="okular"
export TERMINAL="urxvt --perl-lib ~/.urxvt-perl -pe tabbed"

########################################################################
# PROMPT

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
# prompt_err_stat="\
# \`__lasterr=\$?; \
# if [ \$__lasterr = 0 ] ; then \
# echo -ne '\e[1;32m' ; \
# else echo -ne '\e[1;31m' ; \
# fi ; \
# echo \$__lasterr\`$normal"
prompt_err_stat="$cyan\`echo \$?\`$normal"
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
# OTHER VARIABLES

# optimizations
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse'
# more dangerous flags
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse,387'

# some programs' startup scipts need to know the screen res
if [ -n "$DISPLAY" ] ; then
    export DPY_RES=`xdpyinfo | grep dimensions | awk '{ print $2 }'`
    export DPY_RES_X=`echo $DPY_RES | perl -lane 'split /x/ ; print @_[0]'`
    export DPY_RES_Y=`echo $DPY_RES | perl -lane 'split /x/ ; print @_[1]'`
    if [ $DPY_RES_X -ge $(( $DPY_RES_Y*2 )) ] ; then
        # assume that if the x res is that much bigger, we have dual screen
        export SCR_RES_X=$(($DPY_RES_X / 2))
    else
        export SCR_RES_X=$DPY_RES_X
    fi
    export SCR_RES_Y=$DPY_RES_Y
    export SCR_RES=${SCR_RES_X}x${SCR_RES_Y}
fi

# used if username isn't specified
export HGUSER=${USER}@${HOSTNAME}

########################################################################
# COLORS

# set up colors for ls
if [ $is_GNU = 0 ] ; then
    DIRCOLORS=gdircolors
else
    DIRCOLORS=dircolors
fi
if which $DIRCOLORS >&/dev/null ; then
    if [ ! -e ~/.dircolors ] ; then
        $DIRCOLORS --print-database > ~/.dircolors
    fi
    eval `$DIRCOLORS --sh ~/.dircolors`
fi

# grep color syntax is the same as for ls
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='01;32' # bold green


########################################################################
# COMMAND LINE ALIASES

# appends a '&' to a command so it will run in the background
# useful for aliases
function bg_wrapper
{
    "$@" &
}

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
alias T="daemon $TERMINAL"

if ! which realpath >&/dev/null ; then
    alias realpath="readlink -f"
fi


if [ $TERM != "dumb" ] ; then
    THIS_FILE=`realpath $BASH_SOURCE`
    # source this file
    alias jpk="source $THIS_FILE"
    # edit this file
    alias aka='$EDITOR $THIS_FILE'
fi

# handy notes file
alias note='$EDITOR ~/doc/notes.txt'

# common typo, easier to type
alias cd..='cd ..'
alias ..='cd ..'
function cdn()
{
    # do 'cd ..' N times
    local x i s d
    if [ -z "$1" ] ; then 
        return
    fi
    x=$(($1 * ($1 > 0))) # positive or zero
    s=`pwd`
    for i in `seq 1 $x` ; do
        cd ..
    done
    # this is so 'cd -' works properly
    d=`pwd`
    cd $s
    cd $d
}
alias ...='cdn'
# go to the previous pwd
alias prev='cd -'
# cd to the "work directory"
alias cdw="cd $HOME/w"
# cd to the source directory
alias cds="cd $HOME/src"
# mkdir and cd to it
function cdmk() { mkdir -p "$1" ; cd "$1" ; }

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
# see also ack-grep
alias srcgrp="grep -RE --include='*.[ch]' -n"

# ls aliases
# workaround for BSD
if [ $is_GNU = 0 ] ; then
    LS=gls
else
    LS=ls
fi
alias ls="$LS -vF --color=auto"
alias l='ls'
# long listing
alias ll='ls -l'
# list all files
alias la='ls -A'
# list only hidden files
#alias lh='ls -A | egrep "^\.[^./]" | column'
alias lh='ls -Ad .[^.]*'
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
alias rm='/bin/rm -i'
function rm-rf()
{
    echo "Delete these files?"
    ls -dFv --color=auto "$@"
    PS3="Please enter a number: "
    select resp in y n ; do
        if [ "$resp" = "y" ] ; then
            rm -rf "$@"
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
# delete all of the .orig files from a mercurial repo
alias rmuntracked='hg stat -un0 $(hg root) | xargs -0r rm'
# safer mv
alias mv='mv -i'
# safer cp
alias cp='cp -i'
# creates parent dirs if they do not exist
alias mkdir='mkdir -p'
# deletes empty directory tree
alias rmdir='rmdir -p'
# rsync for updating usb drives
alias rsync='rsync -auv'
# the most common apt incantation
alias upgrade="sudo aptitude update && sudo aptitude safe-upgrade"

####################################
# less is more

export LESS="--LONG-PROMPT --RAW-CONTROL-CHARS"

# configure less to page just about anything in a rational way
if which lessfile >&/dev/null ; then
    eval $(lessfile)
fi

# _v_iewer
function v()
{
    if [ -d "$1" ] ; then
        if which tree >&/dev/null ; then
            tree -C "$@" | less -r --LONG-PROMPT
        else
            ls -R --color=always | less -r --LONG-PROMPT
        fi
    else
        less --LONG-PROMPT "$@"
    fi
}

# this is another way to open just about any file the right way
alias open="daemon kfmclient exec"

# sdiff the way it was at IBM
alias sdiff='/usr/bin/sdiff --expand-tabs --ignore-all-space --strip-trailing-cr --width=160'
function dif()
{
    if which colordiff >&/dev/null ; then
        colordiff -u "$@"
    else
        diff -u "$@"
    fi
}
# displays global disk usage by partition, excluding supermounted devices
alias df='df -h -x supermount'
# displays disk usage by directory, in human readable format
alias du='du -h'
# display the processes that are using the most CPU time and memory
alias hogc="ps -e -o %cpu,pid,ppid,user,cmd | sort -nr | head"
alias hogm="ps -e -o %mem,pid,ppid,user,cmd | sort -nr | head"
# ping the way it was at IBM, but better
# -c 5 means send five packets, time out after 5 sec
# -A means adapt interval so as to be fast as possible with only one packet in transit at a time
alias ping='ping -c 5 -A'
# screenshot
alias screenshot="xwd -root -silent | convert xwd:- png:$HOME/screenshot.png"
# remake /dev/dsp
alias mkdsp='sudo mknod /dev/dsp c 14 3 && sudo chmod 777 /dev/dsp'
# open gqview or geeqie
VIEWER=`if which geeqie >&/dev/null ; then echo geeqie ; else echo gqview ; fi`
alias gq="daemon $VIEWER"
# start a new opera window
alias opera='daemon opera -newwindow'
# start a new firefox window
alias ffox='daemon firefox'
# by default, nautilus manages the desktop (icons and such)
alias nautilus='bg_wrapper nautilus --no-desktop --browser'
# start a separate acroread for every document
alias acroread='daemon acroread -openInNewWindow'
# kpdf is better
alias kpdf='daemon kpdf'
# okular is even better
alias okular='daemon okular'
alias pdf="$PDF_READER"
# open office
alias ooffice='daemon ooffice'
alias oocalc='daemon oocalc'
alias oowriter='daemon oowriter'
# open my checking account spreadsheets
alias finances="oocalc ~/doc/finances.ods"
# password database
alias kp="keepassx ~/.keepassx/keepass.kdb"

# open the perl reference
alias perlref="bg_wrapper $PDF_READER ~/doc/perlref-5.004.1.pdf"
# open the bash reference
alias bashref="bg_wrapper $BROWSER ~/doc/bashref.html"
# Linux kernel reference
alias kernelref="bg_wrapper $BROWSER ~/doc/LinuxDocBook/index.html"
# latex reference
alias latexref="bg_wrapper $PDF_READER ~/doc/latex/lshort.pdf"
# python reference
alias pythonref="bg_wrapper $PDF_READER ~/doc/python_ref.pdf"
alias pythondoc="bg_wrapper $BROWSER ~/doc/python/Python-Docs-2.4.2/html/index.html"

# xine media player
alias xine="bg_wrapper xine --enqueue"
# xsnow
alias xsnow="(killall xsnow ; sleep 3 ; exec xsnow -nosanta -notrees -norudolf -nokeepsnow >& /dev/null &)"
# view Folding@Home progress
export fah_log_file=/var/lib/origami/foldingathome/CPU1/FAHlog.txt
alias fah_log="less $fah_log_file"
alias fah_tail="tail -f $fah_log_file"
# descent
alias descent="d1x-rebirth-gl -window -grabmouse"
# azureus
alias azureus='daemon azureus'
# ntpdate
alias ntpdate='sudo ntpdate -u -v ntp.ubuntu.com'
# du on files and dirs in pwd, sorted by size
alias dusrt="du --max-depth=1 --all -k --one-file-system 2>/dev/null | sort -n | cut -f2 | xargs -d '\n' du -sh"
# mathematica needs this env var when using Composite extension on X.org
alias mathematica='(export XLIB_SKIP_ARGB_VISUALS=1 ; mathematica &)'
# Gaim instant messenger
alias gaim='daemon gaim'
alias pidgin='daemon pidgin'
# gkrellm system monitor
alias gkrellm='daemon gkrellm'
# music player
alias m=xmms
# remote desktop
alias rdp="rdesktop -K -g $SCR_RES"

# vmware has been messing with X modifier keys, so start it in Xephyr
alias startvmware="daemon Xephyr :11 -screen 1272x993 && DISPLAY=:11 daemon vmware"

########################################################################
# FUNCTIONS

# show the contents of some bash object, where object is a variable,
# function, or alias.
function show()
{
    local usage name
    name="show"
    usage="Usage: $name <type> <obj>\n\
  type may be one of 'var', 'func', 'alias'\n\
  obj is some object that has been defined in the shell\n\
E.g. 'foo=blah ; $name var foo'\n\
  prints 'blah'\n\
E.g. '$name func $name'\n\
  prints the definition of this function"

    if [ -n "$3" -o -z "$2" ] ; then
        echo -e $usage
        return 1
    fi

    case "$1" in
        "func")
            declare -f "$2"
            ;;
        "var")
            echo "$2=${!2}"
            ;;
        "alias")
            alias "$2"
            ;;
        *)
            echo -e $usage
            return 1
            ;;
    esac
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

# moves specified files to ~/.Trash
# will not overwrite files that have the same name
function trash()
{
    local trash_dir file already_trashed count
    trash_dir=$HOME/.Trash
    for file in "$@" ; do
        if [[ -d $file ]] ; then
            already_trashed=$trash_dir/`basename $file`
            if [[ -n `/bin/ls -d $already_trashed*` ]] ; then
                count=`/bin/ls -d $already_trashed* | /usr/bin/wc -l`
                count=$((++count))
                /bin/mv --verbose "$file" "$trash_dir/$file$count"
                continue
            fi
        fi

        /bin/mv --verbose --backup=numbered "$file" $HOME/.Trash
    done
}

function showcolors()
{
    esc="\033["
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
    echo "# Sedika Signing off for now ;->"
}

function spell()
{
    local word resp

    if [ -z "$1" ]; then
        echo "Usage: spell word1 [ word2 ... ]"
    else
        while [ -n "$1" ] ; do
            word=$1
            shift

            resp=$(echo $word | ispell -a -m -B | grep -v "^[@*]")
            if [ -z "$resp" ] ; then
                # example:
                # $ echo spell | ispell -a -m -B
                # @(#) International Ispell Version 3.1.20 10/10/95, patch 1
                # *
                echo "'$word' is spelled correctly."
            else
                # example:
                # $ echo spel | ispell -a -m -B
                # @(#) International Ispell Version 3.1.20 10/10/95, patch 1
                # & spel 7 0: Opel, spec, sped, spell, spelt, spew, spiel
                resp=$(echo $resp | sed -e 's/&.*://')
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

# if [ $TERM != "dumb" ] ; then
#     fortune
# fi
