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
autoswitch
	;
	; Helper M program for the "autoswitch_in_mupjnl" subtest
	; Does enough updates so a later MUPIP JOURNAL RECOVER or ROLLBACK will need to do a journal autoswitch
	; while in the post-resolve-time part of forward phase.
	;
        set i=0
        tstart ():(serial:transaction="BA")
        set (^a(i),^b(i))=$j(i,10)
        tcommit
        for i=1:1:120000 set (^a(i),^x(i))=$j(i,10)
        set i=i+1
        tstart ():(serial:transaction="BA")
        set (^a(i),^b(i))=$j(i,10)
        tcommit
        zsystem "kill -9 "_$j
	quit
