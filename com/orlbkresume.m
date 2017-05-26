;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2012, 2015 Fidelity National Information	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; A hopefully generic M routine that can be bolted onto existing and
	; future M programs that need online rollback support
orlbkresume
	quit
	; establish incretrap handlers for online rollback
incretrap
	set incretrap("INTRA")="do etrapintrahandler^orlbkresume(%MYSTAT)"
	set incretrap("SHOWDEST")=1			; show destination
	set incretrap("NODISP")=1			; suppress output for expected errors
	if $ztrnlnm("gtm_test_os_machtype")="HOST_HP-UX_PA_RISC" do
	.	set incretrap("expected","%GTM-E-FNOTONSYS")="set $ecode="""",ztlevel=0"
	quit
	; pass in the job id, ^@rtn, and the target $ZLEVEL
init(rtn,reslevel,origetrap)
	set $ETRAP="do ^incretrap"
	set (^%orlbkcycle($job),orlbkcycle)=$ZONLNRLBK
	set ORLBKRESUME=reslevel_":orlbkres^"_rtn
	if $data(origetrap) set ORIGETRAP=origetrap
	if $data(incretrap)=0 do incretrap
	set incretrap("PLACE")=reslevel_":orlbkres^"_rtn
	quit
	; remove orlbkresume bits
shut
	kill ^%orlbkcycle($job),orlbkcycle,ORLBKRESUME
	quit
	; General testing information
stats(msg,zpos)
	set tab=$char(9)
	if '$data(^%orlbkcycle($job)) write "TEST-I-INFO ^%orlbkcycle(",$job,") rolled back",! set ^%orlbkcycle($job)=$ZONLNRLBK
	write "TEST-I-INFO stats : ",msg," : orlbkcycle=",orlbkcycle,tab,"$ZONLNRLBK=",$ZONLNRLBK,tab
	write "^%orlbkcycle(",$job,")=",$select($data(^%orlbkcycle($job)):^%orlbkcycle($job),1:-1),!
	write "$tlevel=",$tlevel,tab,"$trestart=",$trestart,tab,zpos,!
	quit
	; Determine if the application was hit by an online rollback and resume if needed
	; additionally compare the local and ^global stored value for $ZONLRLBK
	; note that you must guard orlbkcycle in tstart (orlbkcycle) for this to work
ifneeded(tpstatus)
	; if a rollback occured, then ^%orlbkcycle($job) != orlbkcycle
	if '$data(^%orlbkcycle($job)) set ^%orlbkcycle($job)=$ZONLNRLBK  ; ^%orlbkcycle was rolled back
	if ^%orlbkcycle($job)'=orlbkcycle do stats("possible online rollback detected",$stack($stack-2,"PLACE"))
	; Online Rollback has NOT occurred if orlbkcycle=$ZONLNRLBK
	quit:orlbkcycle=$ZONLNRLBK
	; Online Rollback has occurred
	set tpstat=$select($tlevel:"restart in TP",1:"NONTP, restart outside TP fence");
	do stats(tpstat,$stack($stack-1,"PLACE"))
	;
	set (^%orlbkcycle($job),orlbkcycle)=$ZONLNRLBK
	if '$data(ORLBKRESUME) write "TEST-W-WARN ORLBKRESUME does not exist",! zshow "*"
	set resumertn=ORLBKRESUME
	write "TEST-I-INFO : going to ",resumertn,!
	zgoto @resumertn
	write "TEST-E-FAIL: zgoto to orlbkresume failed : ",resumertn,!
	goto:$data(ORIGETRAP) @ORIGETRAP
	write "TEST-E-FAIL: could not goto @ORIGETRAP",!
	quit
	; INTRA handler for test/com/incretrap.m
	; must pass newprog by reference to change it here
etrapintrahandler(inerr,resumertn)
	set err=$piece(inerr,",",2),tab=$char(9)
	; Here handle _ONLY_ Online Rollback
	if err'["DBROLLEDBACK" set %NODISP=1 quit	; always display unexpected errors
	write:orlbkcycle=$ZONLNRLBK "TEST-F-FAIL : online rollback error caught, but orlbkcycle=$ZONLNRLBK ,",!
	do stats("$ETRAP : online rollback detected",$piece(inerr,","))
	quit:$tlevel>1					; only allow implicit trigger transaction and NON-TP to proceed
	set (^%orlbkcycle($job),orlbkcycle)=$ZONLNRLBK
	quit
