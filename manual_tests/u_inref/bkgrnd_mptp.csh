#!/usr/local/bin/tcsh -f
#
#$1 = Number of process
# GTM Process starts
if ($1 == "") then
	set jobcnt="5"
else
	set jobcnt=$1
endif
if ($?gtm_test_noisolation == 1) then
$GTM << xyz
view "NOISOLATION":"^a,^b,^c,^d,^e,^f,^g,^h,^i"  
set ^tpnoiso=1
w "NOISOLATION test Enabled"
w "infinite multiple process tp loop starts",!  
w "do mptp($jobcnt,10)",!  do ^mptp($jobcnt,10)
w "infinite multiple process tp loop ends",!  
h
xyz
else
$GTM << xyz
set ^tpnoiso=0
w "infinite multiple process tp loop starts",!  
w "do mptp($jobcnt,10)",!  do ^mptp($jobcnt,10)
w "infinite multiple process tp loop ends",!  
h
xyz
endif
