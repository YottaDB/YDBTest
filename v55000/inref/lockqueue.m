;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; No processes left hung if proc queue is overloaded and released afterwards

lockqueue
	set jdetach=1
	set jnoerrchk=1
	set jmjoname="lockjob"
	set jmaxwait=0
	set jnolock=1
	set jmjoname="lockjob"
	set numlock=70 ; 70 is an arbitrary value. This must exceed the lock queue slot.
	lock +a("xxx","yyy")
	set ^tend=1
	kill ^table
	kill ^lookup
	set ^launch=0
	do ^job("lockjob^lockqueue",numlock,"""""")
	for i=1:1:300 quit:^launch=numlock  hang 1 ; wait for the children to lock themselves.
	write:i=300 "Waited too long for processes to launch.",!
	lock
	do wait^job ; All processes must complete
	; This loop is to make sure that lock+ holds all processes including excessive ones. If lock is bypassed by any of the processes,
	; they will (hopefully) make duplicate/meningless updates in ^table.
	for i=1:1:numlock do
	    . if ($data(^table(i))=0)!(^table(i)<1)!(^table(i)>numlock)!($data(^lookup(i))'=0) do  ; Check values are sane, unique and unmarked
	    ..	 write "One process left hung. "_table(i)_"which completed at the step:"_i
	    . set ^lookup(i)=1 ; mark visited
	quit

lockjob
	set id=$increment(^launch) ; Notify parent right before locking
 	lock +a("xxx","yyy")
 	set ^table(^tend)=id ; Only protection is lock (No TPs).
 	set ^tend=^tend+1   ; if lock doesn't hold processes, those updates will fail.
 	quit
