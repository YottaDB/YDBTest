uzbdrive;   
uzbbasic;
	new lineno
	set $ZTRAP="set $ZTRAP="""" goto ERROR^uzbdrive"
	set (^setrout1,^setrout2)=0
	w "do ^uzbbasic start",!
	do ^uzbbasic
	w "do ^uzbbasic done",!
errtest;
	set $ZTRAP="set $ZTRAP="""" goto ERROR^uzbdrive"
	set (^setrout1,^setrout2)=0
	set ecnt=0
	for lineno=1:1:5  do
	. set zberr($C(lineno+255)_ecnt)=0
	. zbreak forcerr+lineno^uzbmain:"set zberr("""_$C(lineno+255)_ecnt_""")=zberr("""_$C(lineno+255)_ecnt_""")+1"
	. set ecnt=ecnt+1
	do forcerr^uzbmain
	;
initlab	;
	kill
	set $ZTRAP="set $ZTRAP="""" goto ERROR^uzbdrive"
	set (^setrout1,^setrout2)=0
	set ^lineno=0
	set begline=2
	set maxline=43
	for lineno=begline:1:maxline  do
	. set zbcnt($C(lineno+255)_lineno)=0
	. zbreak uzbmain+lineno^uzbmain:"set zbcnt("""_$C(lineno+255)_lineno_""")=zbcnt("""_$C(lineno+255)_lineno_""")+1"
	write "After break points set in initlab: Show the break points and stack:"  zshow "BS"
	set ^uzbmain=$GET(^uzbmain)+1
	set ^caller=$ZPOS
	write "Test zbreak actions with set",!
	write "do ^uzbmain",!  do ^uzbmain
lab0;
	for lineno=begline:1:maxline  do
	. zbreak uzbmain+lineno^uzbmain:"do uzblab1^uzblab1 zcontinue"
	write "After break points set in lab0: Show the break points and stack:"  zshow "BS"
	;
	set ^uzbmain=$GET(^uzbmain)+1
	set ^caller=$ZPOS
	write "Test zbreak actions with action do uzblab1^uzblab1",!
	do ^uzbmain
	;
	write "Now verify data",!
	write "do verify^uzbmain",!  do verify^uzbmain
	quit
	;
ERROR	ZSHOW "*"
	quit
	;
