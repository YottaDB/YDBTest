kiptrestart
	set jmaxwait=0
	; redirect job command output
	do ^job("setjob^kiptrestart",1,"""""")
	do FUNC^waituntilseqno("jnl",0,100,30)
	do ^job("killjob^kiptrestart",1,"""""")
	quit

	; SET some values
setjob
	set $ETRAP="do etrap^kiptrestart"
	set zonlnrlbk=$zonlnrlbk
	for  quit:$data(^ptstop)  do
	.	tstart (zonlnrlbk):serial
	.	if zonlnrlbk='$zonlnrlbk do info^kiptrestart set zonlnrlbk=$zonlnrlbk
	.	set ^a($incr(i))=i
	.	tcommit
	.	hang 0.25	; we want updates, not load
	quit

	; follow the setjob, killing all of ^a
killjob
	set $ETRAP="do killetrap^kiptrestart"
	for  quit:$data(^ptstop)  do
	.	kill ^a		; kill the entire global
	.	hang 0.25	; we want updates, not load
	quit

	; once hit by DBROLLEDBACK, keep looping to verify that we avoid an
	; assert where need_kip_incr was incorrectly maintained
killetrap
	do info^kiptrestart
	set $ecode=""
	for   quit:$data(^ptstop)  do
	. set x=$data(^a)
	quit

stop
	set ^ptstop=10
	halt

etrap
	do info^kiptrestart
	set $ecode=""
	quit

info
	write $ZDATE($horolog,"MON DD 24:60:SS")
	write ?20,"$zonlnrlbk=",$zonlnrlbk
	write ?32,"$trestart=",$trestart,!
	quit
