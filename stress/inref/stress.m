;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2004, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
stress(ntpj,tprj,tpcj) ; ; ; Test of Concurrent transactions
	;
	;	[R]andomly [INT]erfering [TP]
	;	  This cause often a TP to go to its last try
	;	  Needs a lot of CPU because of contention
	;	ntpj=job index upto which NTP is done (always strats from 1)
	;	tprj=job index upto which TPROLLBACK is done
	;	tpcj=job index upto which TCOMMIT is done
	;
	;
	SET $ZT="g ERROR^stress"
	if ntpj>1 w "ntpj Cannot be more than 1 (limitation of the M progrem)",!  q
	;
	Set fnname="stress"
	Set output=fnname_".mjo0",error=fnname_".mje0"
	Set localinstance=^instance
        Open output:newversion,error:newversion
        Use output
        W "PID: ",$J,!
        Close output
	;
	if ($data(iterate)=0) SET iterate=10
	Set unix=$zv'["VMS"
	; Intialize from the script: do lhuge^initdat
	; Intialize from the script: do initcust^initdat(^prime)
	;
	L +^permit
	SET tpflag="NTP"
	For I=1:1:tpcj do
        . If unix J @("job^stress("""_tpflag_""",iterate,I):(output="""_fnname_".mjo"_I_""":error="""_fnname_".mje"_I_""")")
        . Else  J @("job^stress("""_tpflag_""",iterate,I):(STARTUP=""STARTUP.COM"":output="""_fnname_".mjo"_I_""":error="""_fnname_".mje"_I_""")")
	. If I=ntpj SET tpflag="TPR"
	. If I=tprj SET tpflag="TPC"
        . H 2
	; Wait for all jobs to start and get to the point right before grabbing the lock
	set timeout=120 ; times 10 seconds = 20 minutes
	For I=1:1:tpcj do
	. For j=1:1:timeout quit:$data(^PID(I,localinstance))  hang 10
	. if j=timeout write "TEST-E-FAIL jobno ",I," did not start on after ",timeout," seconds.",! halt
	write "Releasing jobs...",!
	lock -^permit	; All job starts at the same time
	write "Each job will start now...",!
	; Check if processes have completed
	; Setting a very long time out here because NON-TP job does not even complete its first iteration before every other TP
	; process is done. It makes a big impact on slow boxes that does only 1 iteration per 1-2 minutes.
	set timeout=240 ; times 10 seconds = 40 minutes
	For I=1:1:tpcj do
	. set done=0
	. kill savelasti
	. ; DO NOT replace the below $data with $get. It triggers the GVUNDEF assert.
	. For j=1:1:timeout do:$data(^lasti(I,localinstance))  quit:done  hang 10
	. . set savelasti=^lasti(I,localinstance)
	. . set done=(savelasti=iterate)
	. if 'done write "TEST-E-FAIL job ",I," did not complete its iteration. It did: ",$get(savelasti)," iterations.",! halt
	write !,"Each job will exit now",!
	q


job(tpflag,iterate,jobno);
	SET $ZT="g ERROR^stress"
	SET localinstance=^instance
	W "PID: ",$J," TYPE:",tpflag,!
	write "Wating for the parent to release lock : ",$zdate($H,"24:60:SS"),!
	new loop
	SET ^PID(jobno,localinstance)=$j
	L +^permit($j)
	F loop=1:1:iterate DO
	. write "iteration number : ",loop,!
	. write "time : ",$zdate($H,"24:60:SS"),!
	. new efill,ffill,gfill,hfill
	. SET (efill(loop),ffill(loop),gfill(loop),hfill(loop))=loop
        . if tpflag'="NTP" TSTART (efill,ffill,gfill,hfill):(serial:transaction="BA")
	. do ^randfill("kill",loop+loop#10+1,loop)
	. do ^randfill("set",loop+loop#10+1,loop)
	. do ^randfill("ver",loop+loop#10+1,loop)
	. if $TRESTART WRITE "TRESTART = ",$TRESTART," For Loop=",loop," TLEVEL=",$TLEVEL,!
        . if tpflag="TPR" TROLLBACK
        . if tpflag="TPC" TCOMMIT
	. S ^lasti(jobno,localinstance)=loop
	w "Successful : ",$zdate($H,"24:60:SS"),!
	q


ERROR   SET $ZT=""
        ZSHOW "*"
        IF $TLEVEL TROLLBACK
        ZM +$ZS
	q
