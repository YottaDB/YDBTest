d002706	;
	; D9I10002706 Nested fprintf calls lead to infinite loop of messages in util_output
	;
	quit
time1	;
	set ^t1=$h
	quit
time2	;
	set t2=$h
	set dif=$$^difftime(t2,^t1)
	zsystem "echo "_dif_" > onereorgtime.txt"
	quit
start	;
	set jmaxwait=0
	do ^job("bkgrnd^d002706",1,"""""")
	quit
bkgrnd	;
	set stop=0
	set t1=$h
	for  quit:stop=1  do
	.	set local=0	; we only want global variables
	.	do ver^lotsvar
	.	do kill^lotsvar
	.	do set^lotsvar
	.	set t2=$h
	.	set dif=$$^difftime(t2,t1)
	.	if dif>60  set stop=1
	zsystem "touch REORG_DONE.TXT"
	quit
