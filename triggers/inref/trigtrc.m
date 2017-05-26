;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2011-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	; Test trigger tracing, ZPRINT, $TEXT, and ZBREAK
	;
	Do ^sstep
	;
	; Should trace from here on out
	;
	Kill ^A
	Set cnt=42
	For i=0:1:3 Do
	. Set cnt=cnt-1
	. Set ^A(i)=i*cnt

	Quit
