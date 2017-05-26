;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8394	;
	; Helper M program for gtm8394.csh.
	; Update BREG and DEFAULT but not AREG.
	;
        for i=1:1:100000 do
        . tstart ():(serial:transaction="BATCH")
        . set ^x(i)=$j(i,2),^b(i)=$j(i*2,2)
        . tcommit
        quit
