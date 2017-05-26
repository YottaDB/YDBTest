#! /usr/local/bin/tcsh -f
if ($3 == "jou") then
$MUPIP set -journal=enable,on,before -reg "*" | & sort -f 
endif
$GTM <<aaa
w "do $1",!  d $2
aaa
chmod 666 *.dat
if (-e *.mjl) then
chmod 666 *.mjl
endif

