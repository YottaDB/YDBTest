mdivis(tpparm)	; ; ; Martin's test to create contention
	;
	if tpparm="tp" set istp=1
	else  set istp=0
	Set output="mdivis.mjo0",error="mdivis.mje0"
	Open output:newversion,error:newversion
	Use output
	Set unix=$ZVersion'["VMS"
	W $ZDate($Horolog,"24:60:SS")," Main task started",! 
	S ^jobcnt=10
	S ^top=700000
	S ^istp=istp
	K ^TEST
	do ^job("job1^mdivis",^jobcnt,"""""")
	W $ZDate($Horolog,"24:60:SS")," Main task ended",! 
	Q
job1
	new tmp
	set jobno=jobindex
	set jobcnt=^jobcnt
	set top=^top
	set istp=^istp
	W $ZDate($Horolog,"24:60:SS")," Job ",jobno," started",! 
	S $ZT="g ERROR"
	view "NOUNDEF"	; for $incr done below not to error out on undefined variables 
	F I=jobno:jobcnt:top D
	. if istp  tstart ():(serial:transaction="BA")
	. set tmp=$incr(^TEST(I),I)
	. if istp  tcommit
	W $ZDate($Horolog,"24:60:SS")," Job ",jobno," ended",! 
	Quit
ERROR	S $ZT=""
	ZSHOW "*"
	ZM +$ZS
	Halt
