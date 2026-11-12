;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1383 : A TP restart that interrupts a LOCK command must not make the next LOCK +, LOCK -, ZALLOCATE or
; ZDEALLOCATE in the restarted transaction issue BADLOCKNEST.
;
; Each label below is run by tp_restart_lock-ydb1383.csh.
;
ydb1383	;
	quit

lockcmd	; $ZCMDLINE is "<command after the restart>|<expected locks>|<command before TSTART>". The transaction restarts
	; with TRESTART until the final retry, where LOCK +(^x,^a) opens region AREG for ^a. Opening a region while
	; holding crit in the final retry restarts the transaction. The command after the restart is the first lock
	; command of the restarted try. <expected locks> lists the locks the process holds after TCOMMIT, as
	; name=level (or name=ZAL for a ZALLOCATE), in the collation order of the names.
	new cmd,expect,precmd,tries,x
	set cmd=$piece($zcmdline,"|",1),expect=$piece($zcmdline,"|",2),precmd=$piece($zcmdline,"|",3)
	set $etrap="do err^ydb1383"
	if $view("REGION","^a")'="AREG" write "FAIL : ^a maps to ",$view("REGION","^a"),", expected AREG",! quit
	if $view("REGION","^x")'="DEFAULT" write "FAIL : ^x maps to ",$view("REGION","^x"),", expected DEFAULT",! quit
	xecute precmd
	set tries=""
	tstart ():serial
	set tries=tries_$select(""=tries:"",1:",")_$trestart
	set x=$get(^x)			; region DEFAULT joins the transaction
	if $trestart<3 trestart		; get to the final retry
	if $trestart=3 lock +(^x,^a)	; region AREG is not open yet, so this restarts the transaction
	xecute cmd
	tcommit
	do checktries
	write "PASS : ",cmd," after the restart did not issue an error",!
	do checklocks(expect)
	quit

checktries	; Check the transaction restarted once from inside LOCK +(^x,^a) in the final retry
	if "0,1,2,3,4"=tries write "PASS : the transaction restarted from inside LOCK +(^x,^a) in the final retry",!
	else  write "FAIL : the $TRESTART values of the tries were ",tries,", expected 0,1,2,3,4",!
	quit

checklocks(expect)	; Check the locks ZSHOW "L" reports, and that another process finds each one held
	new actual,held,i,line,lk,name
	zshow "L":lk
	set i="" for  set i=$order(lk("L",i)) quit:""=i  do
	. set line=lk("L",i)
	. if "LOCK"=$piece(line," ",1) set held($piece(line," ",2))=$piece(line,"LEVEL=",2)
	. if "ZAL"=$piece(line," ",1) set held($piece(line," ",2))="ZAL"
	set actual="",name="" for  set name=$order(held(name)) quit:""=name  do
	. set actual=actual_$select(""=actual:"",1:",")_name_"="_held(name)
	if expect=actual write "PASS : the process holds ",$select(""=expect:"no locks",1:expect),!
	else  write "FAIL : the process holds ",$select(""=actual:"no locks",1:actual),", expected ",$select(""=expect:"no locks",1:expect),! quit
	set name="" for  set name=$order(held(name)) quit:""=name  zsystem "$gtm_dist/mumps -run held^ydb1383 "_name
	quit

held	; Report whether another process holds the lock on the name in $ZCMDLINE
	new name
	set name=$zcmdline
	lock @name:0
	if $test write "FAIL : another process got ",name,", so the first process does not hold it",! lock  quit
	write "PASS : another process finds ",name," held",!
	quit

	; Stages 9 to 17 : a LOCK whose lock name calls an extrinsic. The LOCK is in progress while the extrinsic runs. When
	; the extrinsic returns, the LOCK resumes, unless execution goes on in the frame of the LOCK or an older frame (after a
	; ZGOTO, a TP restart or an error), which abandons the LOCK. Each case checks the locks the process holds at the end.
	;
zg	; Stage 9 : a ZGOTO out of the extrinsic, to the frame of the caller of the LOCK, abandons the LOCK
	set $etrap="do err^ydb1383"
	do zgx
	quit
zgcont	lock +a
	write "PASS : LOCK +a after the ZGOTO did not issue an error",!
	do checklocks("a=1")
	quit
zgx	lock +(a,b($$zgf))
	write "FAIL : the LOCK resumed after the ZGOTO",!
	quit
zgf()	zgoto 1:zgcont^ydb1383
	quit 1
	;
dmx	; Stage 10 (from Direct Mode) : a BREAK in the extrinsic of a lock name
	lock +(a,b($$dmf))
	quit
dmf()	break
	quit 1
	;
tpc	; Stage 11 : TSTART and TCOMMIT in the extrinsic. The LOCK resumes.
	set $etrap="do err^ydb1383"
	lock +(a,b($$tpcf))
	write "PASS : the LOCK resumed after the extrinsic returned",!
	do checklocks("a=1,b(1)=1")
	quit
tpcf()	tstart ():serial
	tcommit
	quit 1
	;
tpr	; Stage 12 : TSTART and TRESTART in the extrinsic. The restart resumes at the TSTART in the extrinsic, so the LOCK
	; resumes.
	set $etrap="do err^ydb1383"
	lock +(a,b($$tprf))
	write "PASS : the LOCK resumed after the extrinsic returned",!
	do checklocks("a=1,b(1)=1")
	quit
tprf()	tstart ():serial
	if '$trestart trestart
	tcommit
	quit 1
	;
tpb	; Stage 13 : TSTART and TROLLBACK in the extrinsic. The LOCK resumes.
	set $etrap="do err^ydb1383"
	lock +(a,b($$tpbf))
	write "PASS : the LOCK resumed after the extrinsic returned",!
	do checklocks("a=1,b(1)=1")
	quit
tpbf()	tstart ():serial
	trollback
	quit 1
	;
eh	; Stage 14 : an error in the extrinsic, handled by the $ETRAP of the extrinsic, which returns 2. The LOCK resumes.
	set $etrap="do err^ydb1383"
	lock +(a,b($$ehf))
	write "PASS : the LOCK resumed after the extrinsic returned",!
	do checklocks("a=1,b(2)=1")
	quit
ehf()	new $etrap
	set $etrap="set $ecode="""" quit 2"
	write 1/0
	quit 1
	;
zgin	; Stage 15 : a ZGOTO that stays in the frames of the extrinsic. The LOCK resumes.
	set $etrap="do err^ydb1383"
	lock +(a,b($$zginf))
	write "PASS : the LOCK resumed after the extrinsic returned",!
	do checklocks("a=1,b(3)=1")
	quit
zginf()	do zging
	quit 0
zginb	quit 3
zging	zgoto $zlevel-1:zginb
	quit
	;
eu	; Stage 16 : an error in the extrinsic that the $ETRAP of the extrinsic does not handle, so the error reaches the frame
	; of the LOCK, whose $ETRAP goes on after the LOCK. That abandons the LOCK.
	set $etrap="set $ecode="""" goto eucont"
	lock +(a,b($$euf))
	write "FAIL : the LOCK resumed after the error",!
	quit
eucont	write "PASS : the error reached the frame of the LOCK",!
	lock +a
	write "PASS : LOCK +a after the error did not issue an error",!
	do checklocks("a=1")
	quit
euf()	new $etrap
	set $etrap="quit 1"
	write 1/0
	quit 1
	;
nest	; Stage 17 : a LOCK in the extrinsic issues BADLOCKNEST, which abandons both LOCKs. The $ETRAP runs in the frame of the
	; extrinsic, so the $ETRAP goes back to this frame with ZGOTO.
	new lvl
	set lvl=$zlevel
	set $etrap="write ""PASS : "",$piece($piece($zstatus,"","",3),""-"",3),"" from the LOCK in the extrinsic"",! set $ecode="""" zgoto lvl:nestcont"
	lock +(a,b($$nestf))
	write "FAIL : no BADLOCKNEST",!
	quit
nestcont	lock +a
	write "PASS : LOCK +a after the BADLOCKNEST did not issue an error",!
	do checklocks("a=1")
	quit
nestf()	lock +c
	quit 1
	;
err	; Report the error, then stop
	write "FAIL : ",$piece($zstatus,",",3,4),!
	set $ecode=""
	trollback:$tlevel
	halt
