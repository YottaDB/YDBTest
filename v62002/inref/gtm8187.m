;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8187	;
	; Do updates in AREG first
	;
	for i=1:1:1000 set ^a2(i)=$j(i,200)
	set ^a1=1
	for i=1:2:1000 kill ^a2(i)
	;
	; Do updates in DEFAULT next
	;
	for i=1:1:10000 set ^b2(i)=$j(i,200)
	set ^b1=1
	for i=1:2:10000 kill ^b2(i)
	quit
