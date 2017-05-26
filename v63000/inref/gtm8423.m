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
gtm8423
	; Load up the DB with transactions
	tstart ()
	for i=1:1:10000 kill ^a(i) set ^a(i)=$j(i,150)
	tcommit
	; Perform more updates to exceed the 2MB initial conversion buffer
	tstart ()
	for i=1:1:3500 kill ^a($random(1000)+1)
	set x=$random(6500)
	for i=x+1:1:x+3500 set ^a(i)=$j($random(i+i),100)
	tcommit
	write "Test Complete. The secondary should not hang or core dump",!
	quit
