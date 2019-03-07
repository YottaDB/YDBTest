;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8047	;
	do ^sstep
	set limit=+$ztrnlnm("gtm_test_vlimit")
	if ('limit) write "TEST-E-FAIL, gtm_test_vlimit is not set.",! quit
	if $&utils.setrlimit(limit,.errno)
        set z=$justify("",1000),z=$translate(z," ",$zchar(2))
        set x=$justify("",98900)
	; at this time the stringpool should be almost full.
	; now create a YDB-E-MEMORY error which in turn ends up doing a stp_gcol
        tstart ():serial
	for i=1:1 set j=i\100,^y(i#100)=$select(j#2=0:z,1:1) write "i = ",i," : $zrealstor = ",$zrealstor,!
        tcommit
        quit
