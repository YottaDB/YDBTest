START(verbose)
	Write "$ZTRAP on entry to ^%X, before New $ZTRAP = ",$ZTRAP,!
	New $ZTRAP
	Set I=0
	Set $ZTRAP="ZGoTo "_$ZLEVEL_":err^per2586c"
	Set bem=$ZTRAP

loop	Do output("^*")
	GoTo loop

err	Set I=I+1 If I>500 Write !,"   PASS",! Quit
	If verbose Write $ZTRAP,! 
	Set X=$ZSTATUS
	GoTo loop

output(%g)
	If @(%g) Set er=1,rm="global not defined"
	If bem'=$ZTRAP Break
	Quit
