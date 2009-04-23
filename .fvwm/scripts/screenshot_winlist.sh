#!/usr/bin/env perl

use strict;
use warnings;

my $SCREENSHOT_ICONDIR = "/dev/shm";

my $w_id = $ARGV[0];
my $iconic = $ARGV[1];

if ($w_id eq "w.id") {
    exit 0
}

# get the window name from xprop
my $name = `xprop -id $w_id WM_NAME`;
chomp($name);
$name =~ s/^WM_NAME\(.*\) = //;
$name =~ s/^"(.*)"$/$1/; # remove initial and final quote (from xprop)
$name =~ s/\*/**/g; # metachar for Fvwm menus
$name =~ s/%/%%/g; # metachar for Fvwm menus
$name =~ s/&/&&/g; # metachar for Fvwm menus
$name =~ s/\^/^^/g; # metachar for Fvwm menus
$name =~ tr/"`/''/; # change all quotes to single quotes

my $len = length($name);

my $max_len = 50;
if ($len > $max_len) {
    my @tmp = split("", $name);
    $name = join("", @tmp[0 .. ($max_len/2 - 2)], "...", @tmp[($len - $max_len/2 + 2) .. $#tmp]);
}

if ($iconic) {
    $name = "($name)";
}

print "AddToMenu ScreenShotMenu \"%${SCREENSHOT_ICONDIR}/${w_id}.png%${name}\" WindowId $w_id WindowListFunc\n";

