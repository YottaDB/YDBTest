#!/usr/local/bin/tcsh -f
$GTM <<\GTM_END
set ^IterNo=0,^PASS="FALSE"
\GTM_END
foreach i(1 2 3)
$GTM <<\GTM_END
set ^modname="DirectMode",^IterNo=^IterNo+1
w !,"Testing TP in direct Mode:New Line"
d ^init(^timeout,^longwait)
set pass=0
tstart ():serial
set tbegtp=$h
x "f unit=1:1  q:pass>^longwait   set pass=$$^difftime($GET(now,$h),tbegtp)  f i=1:1:1000 hang 0.001 set now=$h set ^dummy(i#11,i#13,$j(i,40))=$j(i,$r(200))"
set file=^modname_".logx"
open file:append
use file
W "Loop finished at unit=",unit,!
w "Message inside TP:TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
tcommit
w "Message after TC: TP Timeout does not work at all. Did not trap to the $ztrap routine!!!",!
d ^finish
close file
\GTM_END
$grep "TEST PASSED" DirectModepasslog.logx >>& passlog
if !($status) then
	exit
endif
end
