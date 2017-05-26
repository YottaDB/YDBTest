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
gtm8376d;
	; Variant of ^gtm8376c with more global usages
	;
	set ^z=0,^y=0
	if ^z!(($select(^y:$select($incr(^x):2),1:3)))
	write "$test = ",$test," : ^x = ",$get(^x)," : ^y = ",$get(^y)," : ^z = ",$get(^z),!
	quit
