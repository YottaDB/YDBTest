;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020-2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test case for GTM-8901 where an indirect exclusive NEW can cause sig-11 and/or other errors. This test case
; fails prior to V63010.
gtm8901
	set a=1,b=2,c=3,d=42
	set args="(args,d,i)"
	do subrtn
	zwrite
	quit

subrtn
	for i=1:1:2 new @args set a=3,b=2,c=1,d=24
	set k=a+b+c+d
	quit
