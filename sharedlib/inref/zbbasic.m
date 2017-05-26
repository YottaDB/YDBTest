basic;
	; xecute and zbreak action are same.
	write "Simple zbreak test starts",!
	set begline=2
	set maxline=14	; No comment line should be in between in the called routine from begline to maxline
	set ^caller=$zpos
	;
	set step=1
	write "Set break points",!
	for lineno=begline:1:maxline  do
	. zbreak zbbasic+lineno^zbbasicexec:"set zbbasic("_lineno_")=$get(zbbasic("_lineno_"))+1"
	write "After break points set: Show the break points and stack:"  zshow "BS"
	;
	write "Test xecute",!
	for lineno=begline:1:maxline  do
	. xecute "set zbbasic("_lineno_")=$get(zbbasic("_lineno_"))+1"
	write "Verify xecute",!
	for lineno=begline:1:maxline  do
	. if zbbasic(lineno)'=step write "Test Failed in xecute",! zwr zbbasic
	;
	set step=2
	set (^setrout1,^setrout2)=0
	write "Test zbreak actions",!
	write "do zbbasic^zbbasicexec",!  do zbbasic^zbbasicexec
	;
	write "After zbreak actions: Show the break points and stack:"  zshow "BS"
	write "Now verify data",!
	write "do verify^zbbasicexec",!  do verify^zbbasicexec
	for lineno=begline:1:maxline  do
	. if zbbasic(lineno)'=step write "Test Failed in zbreak action",! zwr zbbasic
	;
	set step=3
	write "Set break points again",!
	for lineno=begline:1:maxline  do
	. set cmd(lineno)="set zbbasic("_lineno_")=$get(zbbasic("_lineno_"))+1"
	. zbreak zbbasic+lineno^zbbasicexec:cmd(lineno)
	;
	write "Test xecute cmd",!
	for lineno=begline:1:maxline  do
	. xecute cmd(lineno)
	write "Verify xecute cmd",!
	for lineno=begline:1:maxline  do
	. if zbbasic(lineno)'=step write "Test Failed in xecute",!  zwr zbbasic
	;
	set step=4
	set (^setrout1,^setrout2)=0
	write "Test zbreak actions again",!
	write "do zbbasic^zbbasicexec",!  do zbbasic^zbbasicexec
	;
	write "After second zbreak actions: Show the break points and stack:"  zshow "BS"
	write "Now verify data",!
	write "do verify^zbbasicexec",!  do verify^zbbasicexec
	for lineno=begline:1:maxline  do
	. if zbbasic(lineno)'=step write "Test Failed in zbreak action",! zwr zbbasic
	;
	write "Simple zbreak test ends",!
	q

