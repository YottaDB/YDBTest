	; routine that will either wait until GT.M has reached a specific seqno
	; OR for a specified amount of time. This lets the test script wait for
	; a more deterministic period instead of sleeping fo an arbitrary value.
	; fast machines will hit the seqno faster than slower machines and slower
	; machines will not be penalized with a requirement for a specific seqno
	; Usage:
	;    $gtm_exe/mumps -run waituntilseqno ("JNL"|"RESYNC") BASE_SEQNO OFFSET_SEQNO [SECONDS_TO_WAIT]
	;	BASE_SEQNO + OFFSET_SEQNO is the target seqno that this
	;	outines is waiting to detect
	;	SECONDS_TO_WAIT - optional. the default is 5 minutes
waituntilseqno
	do parsecmdline
	do FUNC^waituntilseqno(whichseqno,lastseqno,seqno,waittime)
	halt

parsecmdline
	; the $ETRAP handler assumes output to a script file and outputs an exit command
	set $ETRAP="write $char(35),$zstatus,!,""exit(1)"",! zshow ""*"" halt"
	set whichseqno=$$FUNC^%LCASE($piece($zcmdline," ",1))
	set lastseqno=+$piece($zcmdline," ",2)
	set seqno=+$piece($zcmdline," ",3)
	set waittime=+$piece($zcmdline," ",4)
	set:waittime=0 waittime=300 ; default is 5 minutes
	set instlist=$piece($zcmdline," ",5)
	set:instlist="" instlist=0   ; default is just instance 0
	if lastseqno'="" set seqno=seqno+lastseqno
	quit

FUNC(whichseqno,lastseqno,seqno,waittime)
	new start,curseqno,sec
	set start=$horolog,sec=0
	set pid="#PID = "_$justify($job,10)  ; IIRC z/OS has 10 digit PIDs. pad for consistent alignment
	write pid,"# ",$ZDATE(start,"YEAR/MM/DD 24:60:SS"),!
	set curseqno=+$$getcurseqno^getresyncseqno(whichseqno)
	write pid,"# lastseqno = ",lastseqno,", seqno = ",seqno,", curseqno = ",curseqno,!
	set seqno=seqno+lastseqno
	for  quit:(curseqno>seqno)!(sec>waittime)  do
	.	set curseqno=+$$getcurseqno^getresyncseqno(whichseqno)
	.	hang 1
	.	set sec=$$^difftime($horolog,start)
	write pid,"# ",$ZDATE($HOROLOG,"YEAR/MM/DD 24:60:SS"),!
	write pid,"# After ",sec," seconds, the current sequence number is ",curseqno,!
	write "set lastseqno=",curseqno,?32,pid,!
	quit
