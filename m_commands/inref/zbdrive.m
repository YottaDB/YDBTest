zbdrive;   
zbbasic;
	new lineno
	set $ZTRAP="set $ZTRAP="""" goto ERROR^zbdrive"
	set (^setrout1,^setrout2)=0
	w "do ^zbbasic start",!
	do ^zbbasic
	w "do ^zbbasic done",!
errtest;
	set $ZTRAP="set $ZTRAP="""" goto ERROR^zbdrive"
	set (^setrout1,^setrout2)=0
	set ecnt=0
	for lineno=1:1:5  do
	. set zberr(ecnt)=0
	. zbreak forcerr+lineno^zbmain:"set zberr("_ecnt_")=zberr("_ecnt_")+1"
	. set ecnt=ecnt+1
	do forcerr^zbmain
	;
initlab	;
	kill
	set $ZTRAP="set $ZTRAP="""" goto ERROR^zbdrive"
	set (^setrout1,^setrout2)=0
	set ^lineno=0
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. set zbcnt(lineno)=0
	. zbreak zbmain+lineno^zbmain:"set zbcnt("_lineno_")=zbcnt("_lineno_")+1"
	write "After break points set in initlab: Show the break points and stack:"  zshow "BS"
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	write "Test zbreak actions with set",!
	write "do ^zbmain",!  do ^zbmain
lab0;
	for lineno=begline:1:maxline  do
	. zbreak zbmain+lineno^zbmain:"do lab1^zblab1 zcontinue"
	write "After break points set in lab0: Show the break points and stack:"  zshow "BS"
	;
	set ^zbmain=$GET(^zbmain)+1
	set ^caller=$ZPOS
	write "Test zbreak actions with action do lab1^zblab1",!
	do ^zbmain
	;
	write "Now verify data",!
	write "do verify^zbmain",!  do verify^zbmain
	quit
	;
ERROR	ZSHOW "*"
	quit
	;
