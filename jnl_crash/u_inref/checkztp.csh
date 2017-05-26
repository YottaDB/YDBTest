#!/usr/local/bin/tcsh -f
#
echo "Checking database on `pwd`"
$GTM << xyz
w "do checkztp",!  do ^checkztp
h
xyz
