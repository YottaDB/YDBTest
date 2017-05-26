;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
triginchset
	do setup
	do ^echoline
	write "Load triggers in M mode",!
	quit

runInUtf
	set $ETRAP="do ^incretrap"
	do ^echoline
	write "Run GT.M in UTF-8 Mode",!
	write "Access of global post trigger read error works fine regardless of TP state",!
	tstart:$random(2) ():serial ; randomly use TP
	set ^aa("A20")=1
	tcommit:$tlevel
	write "$reference is maintained correctly, should be ^aa(""A20""):",$reference,!
	write "set ^b(2,2)="
	set ^b(2,2)=2	; Should work fine
	write ^b(2,2),!
	do ^echoline
	quit

setup
	do text^dollarztrigger("tfile^trigcommit","trigcommit.trg")
	do file^dollarztrigger("trigcommit.trg",1)
	quit

tfile
	;+^aa(acn=:) -commands=SET -xecute="Set ^aa(acn,acn)=$ztvalue"
