# put a link to this file in /usr/local/lib/site_perl

# start the debugger with `perl -d -M$(basename $THIS_FILE) forker.pl`

# create a terminal upon fork()ing in the debugger
sub DB::get_fork_TTY
{
    open(XT, "3>&1 urxvt -title 'Forked Perl debugger' -e sh -c 'tty 1>&3; while :; do sleep 1 ; done' |")
    	or die("Could not start terminal for debugger: $!\n");
    $DB::fork_TTY = <XT>;
    chomp $DB::fork_TTY;
}

1; # must return true
