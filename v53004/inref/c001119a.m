c001119a;
	; -----------------------------------------------------------------------------------------------------
	; Test the very important optimization in gvcst_search.c which ensures TP restarts are kept
	; to a minimum by avoiding using out-of-date clues.
	; -----------------------------------------------------------------------------------------------------
	;
	set ^jobs=10
	set ^stop=0
	set ^sleep=60+$r(60)
	set jmaxwait=0
	do ^job("child^c001119a",^jobs,"""""")
	hang ^sleep
	set ^stop=1
	do wait^job
	quit
child	;
	view "NOISOLATION":"^TMP"
	set tmp=0
	for i=1:1 quit:^stop=1  do
	.	tstart ():(serial:transaction="BATCH")
	.	set incr=$r(2000)/93
	.	set ^TMP($J)=tmp+incr
	.	tcommit
	set total=$incr(^total,i)
	quit
retrychk;
	set maxallowed=5 ; we have seen most platforms below 1% but a few get to 2 or 3 % occasionally so keep max at 5 for now
	; Check that ratio of "Total # of restarts / Total # of transactions" is less than maxallowed% 
	; This is possible only because we do NOT READ the NOISOLATION global ^TMP in the transaction.
	; All references to ^TMP are only to update it. Never to read it.
	; If we READ it as well, then the # of restarts will dramatically increase as NOISOLATION does not matter then.
	; In that case, we cannot have any such < maxallowed% test as the percent could get as close to even 90+% of restarts.
	set ^totretries=$ztrnlnm("totretries")
	set restartpct=(^totretries/^total)*100
	if restartpct>maxallowed  do
	.	write "C001119-E-PERFISSUE1 : TP Restart % of [",restartpct,"] is greater than allowed limit of ",maxallowed,"%",!
	.	write "C001119-E-PERFISSUE2 : Check for TP performance slowdown",!
	quit
