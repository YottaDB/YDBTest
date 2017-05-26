#! /usr/local/bin/tcsh -f
# Primary in B
cd $PRI_SIDE
$GTM << aaa
w "do ^sptp3(1,5)",!
do ^sptp3(1,5)
h
aaa
