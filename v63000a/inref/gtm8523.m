;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8523	;
	; M program that exercises the code-path which exposed the GTM-8523 issue
	quit
	;
init	;
	; Initialize the databases for DEFAULT and AREG regions
	; Create huge DEFAULT and AREG database file sizes to ensure remap of DEFAULT goes to a new address that
	; does not intersect with old mapping (and hence causes a SIG-11 if GTM-8523 is not fixed)
	set ^apid("init")=$j
	for i=1:1:979 set ^xdummy(i)=$j(i,900)	; Note 979 is chosen so DEFAULT gets FULL with 0 Free Blocks. Changes to
						; this # will cause parent script to fail verify^gtm8523 and abort the test.
	for i=1:1:1000 set ^adummy(i)=$j(i,900)
	;
	set ^x(0)=0		; Keep small first node so cse->first_copy is FALSE initially for TP in parent^gtm8523
	set ^x(1)=$j(1,900)	; Keep big second node in same block that later gets modified by TP in parent^gtm8523
	set ^x(2)=$j(1,900)	; keep ^x(2) so kill ^x(0) and ^x(1) does not kill ^x global altogether
	quit
verify	;
	set freeblks=$$^%PEEKBYNAME("sgmnt_data.trans_hist.free_blocks","DEFAULT")
	if freeblks'=0 write "TEST-E-FAIL : Free Blocks in DEFAULT region is ",freeblks," : Expecting 0. Exiting...",!
	else           write "Free Blocks in DEFAULT region is ",freeblks," : Expecting 0. Continuing...",!
	quit
parent	;
	set x=$get(^xdummy)	; open DEFAULT region first
	set ^apid("Parent")=$j
	set x=$get(^adummy)	; open AREG region next. a remap of DEFAULT would then go past AREG mapped space
	tstart ():(serial:transaction="BATCH")
	for i=1:1:1 set ^xdummy1(i)=$j(i,900)	; create a node that needs to do a file extension when we reach bm_getfree()
	set ^x(1)=$j(2,900)	; update an existing node (node is created by init^gtm8523 invoked before parent^gtm8523)
	tcommit			; because this test runs with white-box case, child^gtm8523 ($gtm_wbox_mrtn is set by parent
				; test script) is invoked and does the file extension of DEFAULT while this pid is sleeping
				; in gdsfilext.
	quit
child	;
	set ^apid("Child")=$j
	for i=1:1:1 set ^xdummy2(i)=$j(i,900)
	; The below causes restart in parent^gtm8523 M process running a TP transaction
	kill ^x(0),^x(1)
	quit
