# .bashrc

################################################################################
# NOTES

# Never start a program from here that will output text.  It screws up things
#   like ssh.  Put those in ~/.bash_profile instead.

################################################################################

# bash_completion has an error, that causes it to fail if you source
# it more than once, thus we make it idempotent
[ -n "$BASH_COMPLETION" ] || . /etc/bash_completion

# this causes output from background processes to be output right away,
# rather than waiting for the next primary prompt
set -b

# set the default file permissions
# the default permissions are 777 for dirs, 666 for files
# the actual permission is given by (default & ~umask)
# e.g. for umask = 0022, file = 644, dir = 755
umask 0022

# this stops crtl-s from freezing the terminal
stty stop ""

################################################################################
# source other rc files
declare -a source_these_files
source_these_files=(\
    $HOME/open_embedded/setup_env.sh\ 
    $HOME/bfin/bfin.sh\ 
)

for i in ${source_these_files[@]}; do
    if [ -e $i ] ; then
	#echo sourcing $i
	source $i
    #else
	#echo not sourcing $i, does not exist
    fi
done

################################################################################
# PATH VARIABLES 

# append PATHs idempotently
[ -z "$PATH" ] && PATH=/bin:/usr/bin
[ -z ${PATH##*/sbin*} ] || PATH=$PATH:/sbin
[ -z ${PATH##*/usr/sbin*} ] || PATH=$PATH:/usr/sbin
[ -z ${PATH##*/usr/local/bin*} ] || PATH=$PATH:/usr/local/bin
[ -z ${PATH##*/usr/local/sbin*} ] || PATH=$PATH:/usr/local/sbin
[ -z ${PATH##*.*} ] || PATH=$PATH:.
[ -z ${PATH##*$HOME/bin*} ] || PATH=$PATH:$HOME/bin
[ -z ${PATH##*$HOME/usr/local/bin*} ] || PATH=$PATH:$HOME/usr/local/bin
[ -z ${PATH##*/usr/X11R6/bin*} ] || PATH=$PATH:/usr/X11R6/bin
[ -z ${PATH##*/usr/games*} ] || PATH=$PATH:/usr/games
[ -z ${PATH##*/usr/local/games*} ] || PATH=$PATH:/usr/local/games
[ -z ${PATH##*/usr/share/games/bin*} ] || PATH=$PATH:/usr/share/games/bin
#PATH="$PATH:.:$HOME/bin:$HOME/usr/local/bin:/usr/X11R6/bin"
#PATH="$PATH:/usr/games:/usr/local/games:/usr/share/games/bin"

#append_var 'LD_LIBRARY_PATH' ':/usr/local/lib'
C_INCLUDE_PATH="$C_INCLUDE_PATH:/usr/local/include"
CPLUS_INCLUDE_PATH="$CPLUS_INCLUDE_PATH:/usr/local/include"
LIBRARY_PATH="$LIBRARY_PATH:/usr/local/lib"
PKG_CONFIG_PATH="$PKG_CONFIG_PATH:/usr/lib/pkgconfig"


################################################################################
# IMPORTANT VARIABLES

# configure less to page just about anything in a rational way
if [ -e $(which lessfile) ] ; then
    eval $(lessfile)
fi

export EDITOR="xemacs"
export BROWSER="/usr/bin/opera -newwindow"
export PAGER="/usr/bin/less --LONG-PROMPT"

export PDF_READER=/usr/lib/kde4/bin/okular
if [ ! -x "$PDF_READER" ] ; then
    export PDF_READER=/usr/bin/kpdf
fi

################################################################################
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
prompt_at="$blue@$normal"
prompt_hostname="$cyan\h$normal"
prompt_jobs="$cyan\j$normal"
prompt_time="$cyan\t$normal"
prompt_pwd="$magenta\w$normal"
prompt_cmd_num="$blue\#$normal"
prompt_err_stat="$bold$?$normal"
prompt_prompt="$blue\$$normal"

PLAIN_PROMPT='[\u@\h][\w](\j)\n\$ '
FANCY_PROMPT="$prompt_open$prompt_time$prompt_close_open$prompt_username$prompt_at$prompt_hostname$prompt_close_open$prompt_pwd$prompt_close_open$prompt_jobs$prompt_close\n$prompt_prompt "

export PS1=$PLAIN_PROMPT
if [[ $TERM == 'rxvt-unicode' ]] ; then
    TERM=rxvt
fi
if [[ $TERM == 'rxvt' || $TERM == 'xterm' || $TERM == 'linux' ]] ; then
    export PS1=$FANCY_PROMPT
fi

# monstrous 3 line prompt example by Robert
#export PS1='\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[0;28m\]Managing \033[1;31m\]\j\[\033[0m\]\[\033[1;30m\]/\[\033[0m\]\[\033[1;31m\]$(ps ax | wc -l | tr -d '\'' '\'')\[\033[0m\]\[\033[1;30m\] \[\033[0m\]\[\033[0;28m\]jobs.\[\033[0m\]\[\033[1;30m\]] [\[\033[0m\]\[\033[0;28m\]CPU Load: \[\033[0m\]\[\033[1;31m\]$(temp=$(cat /proc/loadavg) && echo ${temp%% *}) \[\033[0m\]\[\033[0;28m\]Uptime: \[\033[0m\]\[\033[1;31m\]$(temp=$(cat /proc/uptime) && upSec=${temp%%.*} ; let secs=$((${upSec}%60)) ; let mins=$((${upSec}/60%60)) ; let hours=$((${upSec}/3600%24)) ; let days=$((${upSec}/86400)) ; if [ ${days} -ne 0 ]; then echo -n ${days}d; fi ; echo -n ${hours}h${mins}m)\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:.\n\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[1;31m\]$(ls -l | grep "^-" | wc -l | tr -d " ") \[\033[0m\]\[\033[0;28m\]files using \[\033[0m\]\[\033[1;31m\]$(ls --si -s | head -1 | awk '\''{print $2}'\'')\[\033[0m\]\[\033[1;30m\]] [\[\033[0m\]\[\033[1;31m\]\u\[\033[0m\]\[\033[0;31m\]@\[\033[0m\]\[\033[1;31m\]\h \[\033[0m\]\[\033[1;34m\]\w\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:.\n\[\033[0m\]\[\033[0;31m\].:\[\033[0m\]\[\033[1;30m\][\[\033[0m\]\[\033[1;31m\]\t\[\033[0m\]\[\033[1;30m\]]\[\033[0m\]\[\033[0;31m\]:. \[\033[0m\]\[\033[1;37m\]\$ \[\033[0m\]'

# this sets the title of the terminal window:
# 'user@host: /present/working/directory/ [ previous_command args ]'
# see the Eterm technical docs, "Set X Terminal Parameters"
# 'ESC ] 0 ; string BEL' sets icon name and title to string
# seems to not work when there is a space before \007
if [[ "$TERM" == "xterm" || $TERM == "rxvt" ]] ; then
    #PROMPT_COMMAND='echo -ne "\033]0;[`whoami`@`hostname` `pwd`]$ `history 1 | cut -d\  -f 4-`\007"'
    PROMPT_COMMAND='echo -ne "\033]0;[${USER}@${HOSTNAME}][${PWD/$HOME/~}]\007"'
fi

################################################################################
# OTHER VARIABLES 

# optimizations
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse'
# more dangerous flags
#CFLAGS='-march=pentium4 -O2 -mmmx -msse -msse2 -malign-double -mfpmath=sse,387'

# prevent CTRL-D from immediately logging out
export IGNOREEOF=1

# some programs' startup scipts need to know the screen res
if [[ -n $DISPLAY && -z $SCREEN_RES && -z $SSH_TTY ]] ; then
    #export SCREEN_RES=1024x768
    #export SCREEN_RES=1280x960
    #export SCREEN_RES=`xdpyinfo | grep dimensions | grep -o '[0-9]*x[0-9]*[[:space:]]*pixels' | sed -e 's/pixels//' -e 's/[[:space:]]//'`
    true
fi

# set up colors for ls
if [ ! -r ~/.dircolors ] ; then
    dircolors --print-database > ~/.dircolors
fi
eval `dircolors --sh ~/.dircolors`

# grep colors
# color syntax is the same as for ls
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='01;32'


################################################################################
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

# default editor
alias edit="$EDITOR"
alias E="$EDITOR"

# source this file
THIS_FILE=`readlink -f $BASH_SOURCE`
alias jpk="source $THIS_FILE"
# edit this file
alias aka='$EDITOR $THIS_FILE'
# handy notes file
alias note='$EDITOR ~/doc/notes.txt'

# common typo, easier to type
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'
# go to the previous pwd
alias prev='cd -'
# cd to the "work directory"
work_dir=$HOME/w
alias cdw="cd $work_dir"
unset work_dir
# mkdir and cd to it
function cdmk() { mkdir -p "$1" ; cd "$1" ; } 

# list of processes matching a regex
# ps[kK] should be modified to use pkill/pgrep
alias psg='ps -e -o pid,ppid,user,start_time,cmd | grep -vE "grep|ps[gkK]" | grep -E'
function psk() { kill `psg "$@" | awk '{print $1}'` ; }
function psK() { kill -KILL `psg "$@" | awk '{print $1}'` ; }
# like psg, but shows different info
alias psgaux='ps auxw | grep -vE "grep|psg" | grep -E'

# grep
alias srcgrp="grep -RE --include='*.[ch]' -n"

# ls aliases
alias ls='/bin/ls -vF --color=auto'
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
    for i in "$@" ; do
	if [ -d "$i" ] ; then
	    (
		cd "$i" 
		/bin/ls --color=auto -v -d */
	    )
	fi
    done
}
alias lsd='lsdir'
# display 'canonical' name (guaranteed to be unique and not a symlink)
alias lc='readlink -f'

# clear the screen, Ctrl-L also works
alias cls='clear'
alias clc='clear'
# use symlinks only, treat links to dirs as normal files, interactive
alias ln='/bin/ln -sni'
# a kinder, safer rm
alias rm='/bin/rm -i'
# deletes backup files
alias rmbck='/bin/rm -f ./*.bck ./.*.bck ./*?~ ./.*?~'
# remove all data from file, or create an empty file
alias empty='/bin/cp /dev/null'
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

# less (_v_iewer)
#alias v='less --LONG-PROMPT'
function v()
{
    if [ -d "$1" ] ; then
	tree -C "$@" | less -r --LONG-PROMPT
    else
	less --LONG-PROMPT "$@"
    fi
}

# sdiff the way it was at IBM
alias sdiff='/usr/bin/sdiff --expand-tabs --ignore-all-space --strip-trailing-cr --width=160'
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
# open gqview
alias gq='bg_wrapper gqview'
# start a new opera window
alias opera='bg_wrapper opera -newwindow'
# start a new firefox window
alias ffox='bg_wrapper firefox'
# by default, nautilus manages the desktop (icons and such)
alias nautilus='bg_wrapper nautilus --no-desktop --browser'
# start a separate acroread for every document
alias acroread='bg_wrapper acroread -openInNewWindow'
# kpdf is better
alias kpdf='daemon kpdf'
# open office
alias oocalc='bg_wrapper oocalc'
alias oowriter='bg_wrapper oowriter'
# open my checking account spreadsheets
alias finances="oocalc ~/doc/finances.ods"

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

# start up ssh with compression
alias ssh='ssh -C'
# xine media player
alias xine="bg_wrapper xine --enqueue"
# xsnow
alias xsnow="(killall xsnow ; sleep 3 ; exec xsnow -nosanta -notrees -norudolf -nokeepsnow >& /dev/null &)"
# view Folding@Home progress
#export fah_log_file=/var/lib/folding/foldingathome/CPU1/FAHlog.txt
export fah_log_file=/opt/foldingathome/1/FAHlog.txt
alias fah_log="less $fah_log_file"
alias fah_tail="tail -f $fah_log_file"
# descent
alias descent="d1x-rebirth-gl -window -grabmouse"
# azureus
alias azureus='daemon azureus'
# ntpdate
alias ntpdate='sudo ntpdate -u -v ntp.ubuntu.com'
# du on files and dirs in pwd, sorted by size
alias dusrt='du --max-depth=1 -a -k | sort -n'
# mathematica needs this env var when using Composite extension on X.org
alias mathematica='(export XLIB_SKIP_ARGB_VISUALS=1 ; mathematica &)'
# Gaim instant messenger
alias gaim='daemon gaim'
alias pidgin='daemon pidgin'
# gkrellm system monitor
alias gkrellm='daemon gkrellm'
# music player
alias m=xmms

################################################################################
# FUNCTIONS 

# rsync with delete and confirmation
function synchronize()
{
    local resp
    /usr/bin/rsync --archive --update --verbose --delete --dry-run $@
    select resp in {yes,no} ; do
        if [[ x$resp == xyes ]] ; then
            /usr/bin/rsync --archive --update --verbose --delete $@
            break
        elif [[ x$resp == xno ]] ; then
            break
        fi
    done
}

# backup a small number of important configuration files
function bckupconf()
{
    pushd $HOME
    tar -jcvf config`date +%m%d%y`.tar.bz2 \
        --exclude=.fvwm/cache/* \
        --exclude=.fvwm/archive/* \
        --exclude=.emacs.d/backup/* \
        --exclude=.opera/cache4/* \
        --exclude=.opera/images/* \
        bin/ .fvwm/ .gnupg/ \
        .emacs.d/ .emacs \
        .xinitrc .Xresources .xsession \
        .inputrc .bashrc .dircolors \
        .opera
    popd
}


# often used form of rename
function rename_d()
{
    local str
    str=$1
    shift 1
    rename "s/$str//" $@
}

# creates a dated tarball
function tarball()
{
    name=$1
    shift
    tar zcvf $name-`date +%Y%m%d`.tar.gz "$@"
}

# moves specified files to ~/.Trash
# will not overwrite files that have the same name
function trash()
{   local trash_dir=$HOME/.Trash
    for file in "$@" ; do 
        if [[ -d $file ]] ; then
            local already_trashed=$trash_dir/`basename $file`
            if [[ -n `/bin/ls -d $already_trashed*` ]] ; then
                local count=`/bin/ls -d $already_trashed* | /usr/bin/wc -l`
                count=$((++count))
                /bin/mv --verbose "$file" "$trash_dir/$file$count"
                continue
            fi
        fi
        
        /bin/mv --verbose --backup=numbered "$file" $HOME/.Trash
    done
}

# these functions are not mine

#Shows the colors in a kewl way...party stolen from HH :)
#function colors()
#{
#       # Display ANSI colours.
#       #
#    esc="\033["
#    echo -e "\t  40\t   41\t   42\t    43\t      44       45\t46\t 47"
#    for fore in 30 31 32 33 34 35 36 37; do
#        line1="$fore  "
#        line2="    "
#        for back in 40 41 42 43 44 45 46 47; do
#            line1="${line1}${esc}${back};${fore}m Normal  ${esc}0m"
#            line2="${line2}${esc}${back};${fore};1m Bold    ${esc}0m"
#        done
#        echo -e "$line1\n$line2"
#    done
#
#    echo ""
#    echo "# Example:"
#    echo "#"
#    echo "# Type a Blinkin TJEENARE in Swedens colours (Yellow on Blue)"
#    echo "#"
#    echo "#           ESC"
#    echo "#            |  CD"
#    echo "#            |  | CD2"
#    echo "#            |  | | FG"
#    echo "#            |  | | |  BG + m"
#    echo "#            |  | | |  |         END-CD"
#    echo "#            |  | | |  |            |"
#    echo "# echo -e '\033[1;5;33;44mTJEENARE\033[0m'"
#    echo "#"
#    echo "# Sedika Signing off for now ;->"
#}

# I-Spell @ work: ENGLISH
function spell()
{
    local CHATTO

    if [ $# -ne 1 ]; then
        echo -e "\033[1;32mUSAGE: \033[33mis word_to_check\033[0m"
    else
        CHATTO=$( echo $* | awk '{print $1}' )
        shift 

        echo -e "----------------------------------------------------->\n"
        echo $CHATTO | ispell -a -m -B |grep -v "@"
        echo -e "----------------------------------------------------->"
    fi
}

