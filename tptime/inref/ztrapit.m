ztrapit	;
time	;new $ztrap
	;SET $ztrap="g ERROR^init"
	set $ZTRAP=""
	set elaptime=$$^difftime($GET(tendtp),$GET(tbegtp))
	set file=^modname_".logx",passfile=^modname_"passlog.logx"
	if $tlevel trollback
	if (elaptime>(^timeout-2))&(elaptime<(^timeout+^delta+1))  DO
	.  ; if elaptime is >= timeout-1 (allow a window of -1 and +delta) .and. elaptime <= timeout+delta 
	.  ; W !,"Timed out in ",elaptime," sec"
	.  if (^modname="DirectMode") do
	.  .	open passfile:append
	.  .	use passfile
	.  write !,"ZTRAP is called"
	.  write !,"Timed out as expected"
	.  ; W !,"Routine:",$P($P($zstatus,",",2,2),"+",1,1)," STAT:",$P($zstatus,",",3,4),!
	.  write !,"ZSTATUS:",$P($zstatus,",",3,4),!
	.  write !,"TEST PASSED",! 
	.  set ^PASS="TRUE"
	. if (^modname="DirectMode")  close passfile
	else  do  
	.  ; Error Occured
	.  open file:append
	.  use file
	.  write !,"Timed out in ",elaptime," sec"
	.  if elaptime>(^timeout+^delta) w !,"Too late. TEST FAILED",! 
	.  else  do
	.  .  if elaptime<^timeout w !,"Too early. TEST FAILED",!
	.  .  else  w !,"Not too late, not too early. Still TEST FAILED",!
	.  w !,"ZSHOW ""*""",!
	.  zshow "*"
	. write "End of Iteration : ",^IterNo,!
	. write "================================================================================="
	. close file
	if (^PASS="TRUE")  do
	.  set ^IterNo=0
	.  quit
	else  if ((^IterNo=3)&(^PASS="FALSE")) do
	.	if (^modname="DirectMode") do
	.	.	open passfile:append
	.	.	use passfile
	.     write "TEST FAILED",!
	.     write "See"_^modname_".log for details"
	.     set ^IterNo=0
	.     if (^modname="DirectMode")  close passfile
	else  if (^modname'="DirectMode")  do 
	.  lock
	.  do ^driver
	quit
