;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for GTM-9311 - test that calling ^%YGBLSTAT doesn't destroy the values of the 'x' and 'd' vars
;
; Note this test is necessarily invoked in heredoc mode to provide answers to the interactive replies of the
; %YGBLSTAT entry point we need to test.
;
	kill x,d			; Make sure these have no values
	do ^%YGBLSTAT
	write !
	set err=0
	if ($data(x)'=0) write "FAILURE: Value 'x' was destroyed across the call",!! set err=err+1
	if ($data(d)'=0) write "FAILURE: Value 'd' was destroyed across the call",!! set err=err+1
	write:(0=err) "SUCCESS - variables were protected across call",!!

