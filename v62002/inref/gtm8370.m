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
gtm8370	;
	; This tests the following codepath.
	; MERGE GVN=LVN where GVN has a trigger and inside the trigger, a runtime error occurs.
	; And we handle the error by doing ZGOTO and unwinding the M frames.
	; And redoing the MERGE sequence again.
	; In between, randomly we do a ZSHOW to verify that works fine inspite of the interrupted MERGE
	;
        set $etrap="do unwind^gtm8370"
        for i=1:1:10  do tp
        quit
tp      ;
        if $zlevel>10 quit
        set y($zlevel)="",y($zlevel*100)=""
        tstart ():serial
        if $random(2) zshow "v":x kill x
        merge ^x=y
        tcommit
        quit
trig    ; this is the entry point for the trigger invoked as part of the "merge" done above
        do tp
        write 1/0
        quit
unwind  ;
errloop if '$random(10) zshow "v":x  kill x
        zgoto:$ztlevel -1:errloop
        trollback
        quit
init    ; this is the entry point to load triggers in the database before the main routine executes
        if $ztrigger("item","+^x(:) -commands=S -xecute=""do trig^gtm8370""")
        quit

