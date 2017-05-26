mprtpzt ;
	s $ztrap=""
	d ztrapit
	view "trace":0
	;zwrite ^mproftp
	d examinf^mproftp("^mproftp")
	q
ztrapit	;
	set $ZTRAP=""	
	set tendtp=$h
	set elaptime=$$^difftime($GET(tendtp),$GET(tbegtp))
	if $tlevel trollback
	if (elaptime>(^timeout-1))&(elaptime<(^timeout+^delta+1))  DO
	.  W !,"Timed out as expected"
	.  W !,"ZSTATUS:",$P($zstatus,",",3,4),!
	.  W !,"TEST PASSED",! 
	else  DO
	.  ; Error Occured
	.  if ^MAXTRIES>0 do
	.  .  set ^MAXTRIES=^MAXTRIES-1		; Due to load or due to periodic fsync/msync
	.  .  view "trace":0:"^mproftp"		; It might have taken longer time to return
	.  .  kill ^mproftp			; Try rerunning the entire test upto 3 times
	.  .  do ^mproftp(^timeout,^longwait)
	.  W !,"Timed out in ",elaptime," sec"
	.  if elaptime>(^timeout+^delta) w !,"Too late. TEST FAILED",! 
	.  else  DO
	.  .  if elaptime<^timeout w !,"Too early. TEST FAILED",!
	.  .  else  W !,"Not too late, not too early. Still TEST FAILED",!
	.  w !,"ZSHOW ""*""",!
	.  ZSHOW "*"
	q
