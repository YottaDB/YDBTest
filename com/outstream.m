;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
outstream()
	;
	; Filter for output files (outstream.log and subtest.log) using GT.M.
	;
	; Since Read and Write are to the same IO device, limited to STDIN input & STDOUT output.
	; Typical usage:
	;    cat subtest.log_actual | mumps -run %XCMD 'do ^outstream()' > subtest.log_m
	;

	; Increase maximum string length
	use $principal:width=1048576

	; Let any test have any free-form debugging info it wants, as long as it is padded with GTM_TEST_DEBUGINFO
	; Don't prepend with ##FILTERED## since outstream.awk will do it.
	;
	do repeol^awk("GTM_TEST_DEBUGINFO","GTM_TEST_DEBUGINFO.*")

	quit
