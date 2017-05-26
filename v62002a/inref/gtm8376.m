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
gtm8376	;
	; There are 6 test cases for GTM-8376. Each of them are in separate M modules gtm8376a.m thru gtm8376f.m
	; as otherwise having them in the same module causes a compile of each of the test case to SIG-11
	; (with pre-V62002A which does not have the fix and when $gtm_boolean=0) since they are in the same M module.
	;
	; This module only exists to serve as a pointer to the individual 6 test cases and is not run or even compiled.
	;
	quit
