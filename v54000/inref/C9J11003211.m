;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; C9J11-003211 - Require option to run both the M-Standard compliant Exclusive Kill (XKILL) and the historical
; 	         GTM non-compliant algorithm.
;
; Option is implemented via environment-var/logical $gtm_stdxkill/GTM_STDXKILL (UNIX/VMS)
;
; This test will obtain the current setting for this env-logical and determine what behavior is appropriate and expected.
;

	kill  kill *
	set Val("")=0,Val(0)=0,Val(1)=1,Val("YES")=1,Val("NO")=0,Val("TRUE")=1,Val("FALSE")=0
	set gtmstdxkill=$$FUNC^%UCASE($select(""'=$ztrnlnm("ydb_stdxkill"):$ztrnlnm("ydb_stdxkill"),1:$ztrnlnm("gtm_stdxkill")))
	set $ETrap="Goto EnvERR"
	set gtmstdxkill=Val(gtmstdxkill)
	set $ETrap=""
	write !,"C9J11-003211 - "
	write $select(gtmstdxkill=1:"M-Standard",gtmstdxkill=0:"GTM",1:"**UNWKNOWN**")
	write " exclusive kill testing",!
	set A=1
	set B=2
	set C=3
	set E=4
	do X(.A,.B)
	; One of these two Writes will print pass/fail on our expected results
	write:gtmstdxkill $Select((($Data(A)=0)&($Data(B)=0)&$Data(C)&($Data(D)=0)&($Data(E)=0)):"PASS",1:"FAIL"),!!
	write:'gtmstdxkill $Select(($Data(A)&$Data(B)&$Data(C)&($Data(D)=0)&($Data(E)=0)):"PASS",1:"FAIL"),!!
	quit

X(C,D)	kill (C,D,gtmstdxkill)
	quit

EnvERR	if $ZStatus["UNDEF" write "Invalid setting for ydb_stdxkill/gtm_stdxkill: ",gtmstdxkill,! quit
	write !!,"Unknown error in C9J11-003211",!!
	zshow "*"
	quit
