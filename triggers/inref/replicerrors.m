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
; Induce an error in the update process
replicerrors
	do setup
	set gbl=$random(5)
	ztrigger @gbl(gbl)
	kill ^ETRAP
	set gbl=$random(5)
	ztrigger @gbl(gbl)
	quit

setup
	set gbl(0)="^a",gbl(1)="^b",gbl(2)="^c",gbl(3)="^d",gbl(4)="^e"
	do text^dollarztrigger("tfile^replicerrors","replicerrors.trg")
	do file^dollarztrigger("replicerrors.trg",1)
	set ^ETRAP="do error^replicerrors set $ecode="""""
	quit

induceerror
	set:$data(^ETRAP) $ETRAP=^ETRAP
	; Avoid inducing an error
	set:0=+$ztrnlnm("avoiderror") x=1/0
	quit

error
	write "===Error handler invoked===",!
	write $piece($zstatus,",",2),!
	zshow "s"
	quit

; Triggers that will induce an error in the update process
tfile
	;+^a -command=ZTR -xecute="do induceerror^replicerrors"
	;+^b -command=ZTR -xecute="do induceerror^replicerrors"
	;+^c -command=ZTR -xecute="do induceerror^replicerrors"
	;+^d -command=ZTR -xecute="do induceerror^replicerrors"
	;+^e -command=ZTR -xecute="do induceerror^replicerrors"

