;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8269	;
	; GTM-8269 KILL of global with NOISOLATION removes extra global nodes
	;
	set ^PROCACT(1)="1a"
	view "NOISOLATION":"+^PROCACT"
	tstart ():serial
	set ^PROCACT(1)="1b"
	kill ^PROCACT(1)
	do ^job("child^gtm8269",1,"""""")
	tcommit
	write "Expecting ZWRITE ^PROCACT to show ^PROCACT(2)=""2a""",!
	write "----------------------------------------------------",!
	zwrite ^PROCACT
	quit
child	;
	set ^PROCACT(2)="2a"
	quit
