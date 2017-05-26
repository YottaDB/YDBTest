;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Load a trigger for a process to load and execute. While available to all process,
; we simulate exclusive access by embedding $job in the trigger spec and name.
imptpdztrig(trigno,canusetp)
	new action,ztrigret
	set canusetp=1+$get(canusetp,0)
	set trigno=$get(trigno,1)
	set ztrigret=1
	set action=$random(20) ; delete 40% ; add %15
	if action<8 set ztrigret=$$delete(trigno,canusetp)
	if action>16 set ztrigret=$$add(trigno,canusetp)
	; Issue a ztrigger command 33% of the time (trigger may not exist)
	xecute:'$random(3) "ztrigger ^%imptpdztrig(trigno,$job)"
	quit:$quit ztrigret
	quit

; Testing via the command line - was useful back when this caused trigger failures
test(id)
	new i
	for i=1:1:$get(^%imptpdztrigcnt,10) do ^imptpdztrig($get(id,99),1)
	quit

job
	new i
	view "JOBPID":1
	if +$zcmdline set ^%imptpdztrigcnt=+$zcmdline
	else  kill ^%imptpdztrigcnt
	set i=$ztrigger("item","-imptpdztrig*")
	for i=1:1:5 job test^imptpdztrig(i)
	quit

; Starting V6.2-001 TRIGMODINTP is no longer valid, and this routine was built with this model in mind, so test for it
; If true, return 10
canmodtrigintp()
	new canmod,testtrig,$ETRAP
	; Disable $ztrigger() testing in IMPTP with this env var
	if +$ztrnlnm("gtm_test_disable_dztrigger") quit:$quit 0
	set $ETRAP="set $ecode="""" trollback:$tlevel -1 quit:$quit canmod quit"
	set testtrig="^%imptpmodtrigintp -commands=ZTR,SET -xecute=""set:$ZTLEVEL=1 ^%imptpmodtrigintp=10"" -name=%imptpmodtrigintptest"
	set canmod=0
	tstart ()
	if $ztrigger("item","+"_testtrig)
	if $random(2) xecute "ztrigger ^%imptpmodtrigintp"
	else  set ^%imptpmodtrigintp=0
	if $ztrigger("item","-"_testtrig)
	set canmod=^%imptpmodtrigintp
	kill ^%imptpmodtrigintp
	tcommit
	quit:$quit canmod

; Add / Delete trigger operations
add(trigno,tp)
	new trigspec,wraptp
	set trigspec="+"_$$gettrigspec(trigno)
	set wraptp=$random(tp)
	if wraptp tstart ()
	set ztrigret=$ztrigger("item",trigspec)
	if wraptp tcommit
	if $ztrigger("select",$$gettrigname(trigno))
	quit ztrigret

delete(trigno,tp)
	new trigspec,wraptp
	set trigspec="-"_$select($random(2):$$gettrigname(trigno),1:$$gettrigspec(trigno))
	set wraptp=$random(tp)
	if wraptp tstart ()
	set ztrigret=$ztrigger("item",trigspec)
	if wraptp tcommit
	if $ztrigger("select",$$gettrigname(trigno))
	quit ztrigret

; Trigger specification / name
gettrigname(trigno) quit "imptpdztrig"_trigno_"S"_$job
gettrigspec(trigno)
	new trigspec
	set @("trigspec="_$piece($text(triggers+0^imptpdztrig),";",2))
	set:(3<$random(10)) trigspec=$piece(trigspec,"ZTR",1)_"ZTR,SET"_$piece(trigspec,"ZTR",2)
	quit trigspec
triggers ;"^%imptpdztrig("_trigno_","_$job_") -commands=ZTR -xecute=""set $ztslate=$ztriggerop_$char(32,94)_$ztname"" -name=imptpdztrig"_trigno_"S"_$job
