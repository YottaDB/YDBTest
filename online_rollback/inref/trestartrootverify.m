trestartrootverify
	set jmaxwait=0
	; redirect job command output
	set file="rootverifyjobs.out"
	open file:newversion
	use file
	do ^job("setjob^trestartrootverify",1,"""""")
	do FUNC^waituntilseqno("jnl",0,100,30)
	do ^job("killjob^trestartrootverify",1,"""""")
	close file
	quit

setjob
	set $ETRAP="do etrap^trestartrootverify"
	set zonlnrlbk=$zonlnrlbk
	for  quit:$data(^ptstop)  do
	.	tstart ():serial
	.	if zonlnrlbk='$zonlnrlbk do info^trestartrootverify set zonlnrlbk=$zonlnrlbk
	.	set ^a($incr(i))=i
	.	tcommit
	.	hang 0.25  ; we want updates, not load
	quit

	; follow the setjob, killing in ^a
killjob
	set $ETRAP="do etrap^trestartrootverify"
	for  quit:$data(^ptstop)  do
	.	kill ^a($incr(i))
	.	hang 0.25  ; we want updates, not load
	quit

stop
	set ^ptstop=10
	halt

etrap
	do info^trestartrootverify
	set $ecode=""
	quit

info
	write $ZDATE($horolog,"MON DD 24:60:SS")
	write ?20,"$zonlnrlbk=",$zonlnrlbk
	write ?32,"$trestart=",$trestart,!
	quit
