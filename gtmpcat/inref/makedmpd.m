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
;
; Routine that at least on V6.0-002 and later will attach to the journal and receive pools using
; $ZPEEK() to see what gets dumped. On versions prior to V6.0-002, we won't be attached to much
; of anything since we can't do updates in the normal case.
;
	Set gtmver=$Piece($ZVersion," ",2)
	If ('("V6.0-002"]gtmver)) Do
	. Set $ETrap="Do poolnotfound(""jnlpool"")"	; If fails, see if expected message and resume at nojnlpool below
	. Xecute "Set tst=$ZPeek(""nlrepl"",0,8,""Z"")"
nojnlpool
	;
	If ('("V6.0-002"]gtmver)) Do
	. Set $ETrap="Do poolnotfound(""recvpool"")"	; If fails, see if expected message and resume at nojnlpool below
	. Xecute "Set tst=$ZPeek(""rpcrepl"",0,8,""Z"")"
norecvpool
	;
	; Now suicide to create a core
	;
	ZSystem "/bin/kill -4 "_$Job
	Write "Waiting to die",!
	Hang 10
	ZMessage 150377788	; generates core if other methods fail
