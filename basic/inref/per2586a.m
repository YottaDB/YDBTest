START(verbose)
	Write "$ZTRAP on entry to ^%X, before New $ZTRAP = ",$ZTRAP,!
	New $ZTRAP
	Set I=0
	Set $ZTRAP="ZGoTo "_$ZLEVEL_":err^per2586a"
	Set bem=$ZTRAP

loop	Do output(".")
	GoTo loop

err	Set I=I+1  If I>400  Write !,"   PASS",! Quit
	If verbose Write !,$PIECE($ZSTATUS,",",2,999)
	If verbose Write !,"$ZTRAP at err^%x = ",$ZTRAP,!,"**",I,!
	If bem'=$ZTRAP Break
	GoTo loop

output(%g)
	If @("'$DATA("_%g_")")  Set er=1,rm="global not defined"
	If bem'=$ZTRAP Break
	Quit
