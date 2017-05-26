;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7636	;

start	;
	set njobs=1
	set jmaxwait=0
	set jnoerrchk=1	; Don't bother error checking the mje files
	do ^job("thread^gtm7636",njobs,"""""")
	quit

stop	;
	set ^stop=1
	do wait^job
	quit

thread	;
	write "PID = ",$job,!
	set $etrap="do err^gtm7636"
	for  quit:$data(^stop)  do
	. set i=$incr(i)
	. tstart ():serial
	. set ^a(i,$job)=$j(i,200)
	. tcommit:$tlevel
	. set ^b(i,$job)=$j(i,200)
	. set ^c(i,$job)=$j(i,200)
	. set ^d(i,$job)=$j(i,200)
	. set ^lasti($job)=i
	quit

err	;
	set $etrap="zwrite $zstatus  halt"
	zwrite $zstatus
	write "$REFERENCE=",$reference,!
	write "$TLEVEL = ",$tlevel,!
	; At this point, we are guaranteed that $reference matches with the last update that happened in thread
	; (be it TP or non-TP) that encountered the GBLOFLOW/DBFILERR error and so the below update is guaranteed
	; to trigger a MMREGNOACCESS error as well.
	set @$reference=$j(i,200);	; Trigger MMREGNOACCESS error
	; Code never reaches here
	write $zsigproc($job,4),!	; Get a core whenever this happens
	halt
