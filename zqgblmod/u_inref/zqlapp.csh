#! /usr/local/bin/tcsh -f
#
# Now check zqgblmod
cd $PRI_SIDE
$GTM << aaa
w "do ^zqlapp(11,100)",!
do ^zqlapp(11,100)
h
aaa
