;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; $ZTEXIT and implicit transaction cases for r208/ztexit_implicit_tp-ydb1342
;
; Each stage counts the runs of $ZINTERRUPT in ^c and the runs of the trigger in ^t. $ZINTERRUPT also notes ^t in
; ^tsav(<run>), to show the update (and its trigger) completed before $ZINTERRUPT ran.
;
ydb1342
	quit

settrig	; SET that invokes a SET trigger
	do init("set")
	set $ztexit=1
	set ^x(1)=1
	set $ztexit=0
	do check("SET ^x(1)=1",1,1)
	quit

ztrignone	; ZTRIGGER with no trigger defined
	do init("")
	set $ztexit=1
	ztrigger ^x(1)
	set $ztexit=0
	do check("ZTRIGGER ^x(1)",1,0)
	quit

ztrigtrig	; ZTRIGGER that invokes a ZTRIGGER trigger
	do init("ztr")
	set $ztexit=1
	ztrigger ^x(1)
	set $ztexit=0
	do check("ZTRIGGER ^x(1)",1,1)
	quit

killtrig	; KILL that invokes a KILL trigger
	do init("kill")
	set ^x(1)=1
	set $ztexit=1
	kill ^x(1)
	set $ztexit=0
	do check("KILL ^x(1)",1,1)
	write $select(0=$data(^x(1)):"PASS : ",1:"WRONG : "),"$data(^x(1))=",$data(^x(1))," after the KILL (expected 0)",!
	quit

ztrigitem	; $ZTRIGGER("ITEM") that loads a trigger
	do init("")
	set $ztexit=1
	set ok=$ztrigger("item","+^x(*) -commands=set -xecute=""set ^t=$get(^t)+1""")
	set $ztexit=0
	write $select(ok:"PASS : ",1:"WRONG : "),"$ZTRIGGER(""ITEM"") returned ",ok," (expected 1)",!
	do check("$ZTRIGGER(""ITEM"")",1,0)
	quit

trigerr	; SET whose trigger issues an error, so the implicit transaction is rolled back
	do init("set","y=1/0")
	kill ^err
	set $ztexit=1
	do trigerrset
	set $ztexit=0
	; Print only the mnemonic on success, as the test framework flags error message text in the output files
	write $select($get(^err)["DIVZERO":"PASS : $ETRAP saw DIVZERO",1:"WRONG : $ETRAP saw: "_$get(^err)),!
	do check("SET ^x(1)=1 with a failing trigger",1,0)
	write $select(0=$data(^x(1)):"PASS : ",1:"WRONG : "),"$data(^x(1))=",$data(^x(1))," after the rolled back SET (expected 0)",!
	quit

trigerrset	; Do the failing SET with an $ETRAP that notes the error and returns to the caller
	; The $ETRAP leaves the error alone inside the trigger ($ZTLEVEL>0), so it ends the trigger and rolls back the SET
	new $etrap
	set $etrap="if 0=$ztlevel set ^err=$zstatus,$ecode="""""
	set ^x(1)=1
	quit

intp	; The same kinds of update inside an explicit transaction
	new cintp
	do init("set")
	set $ztexit=1
	tstart ()
	set ^x(1)=1
	ztrigger ^x(2)
	set cintp=$get(^c,0)
	tcommit
	set $ztexit=0
	write $select(0=cintp:"PASS : ",1:"WRONG : "),"$ZINTERRUPT ran ",cintp," time(s) before the TCOMMIT (expected 0)",!
	do check("TCOMMIT",1,1)
	quit

dflt	; ZTRIGGER with the default $ZINTERRUPT, which writes a *_JOBEXAM.ZSHOW_DMP_* file each time it runs
	if $ztrigger("item","-*")
	kill ^c,^t,^tsav,^x
	set $zinterrupt="if $zjobexam()"
	set $ztexit=1
	ztrigger ^x(1)
	set $ztexit=0
	quit

ctrl	; Controls: $ZTEXIT false, and an explicit TSTART/TCOMMIT with $ZTEXIT true
	do init("set")
	set ^x(1)=1
	do check("SET ^x(1)=1 with $ZTEXIT false",0,1)
	do init("")
	set $ztexit=1
	tstart ()
	tcommit
	set $ztexit=0
	do check("TSTART ()  TCOMMIT",1,0)
	quit

init(cmds,xecute)	; Remove triggers and globals left by an earlier stage, load a trigger for cmds (if any), set $ZINTERRUPT
	; The trigger counts its runs in ^t, then does xecute (if any)
	if $ztrigger("item","-*")
	kill ^c,^t,^tsav,^x
	set xecute="set ^t=$get(^t)+1"_$select(""=$get(xecute):"",1:","_xecute)
	if ""'=cmds if $ztrigger("item","+^x(*) -commands="_cmds_" -xecute="""_xecute_"""")
	set $zinterrupt="set ^c=$get(^c)+1,^tsav(^c)=+$get(^t)"
	quit

check(what,c,t)	; Check $ZINTERRUPT ran c times and the trigger t times, and that the update was done before $ZINTERRUPT
	new ok
	set ok=(c=$get(^c,0))&(t=$get(^t,0))&((0=c)!(t=$get(^tsav(1),-1)))
	write $select(ok:"PASS : ",1:"WRONG : "),what," : $ZINTERRUPT ran ",$get(^c,0)," time(s) (expected ",c,")"
	write ", the trigger ran ",$get(^t,0)," time(s) (expected ",t,")"
	if c write ", the trigger had run ",$get(^tsav(1),"<none>")," time(s) when $ZINTERRUPT ran (expected ",t,")"
	write !
	quit
