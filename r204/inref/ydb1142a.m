;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Tests for a bug where adding implicit returns would cause a failure.
; When the mumps compiler encounters a FALLINTOFLST warning during compile time,
; it adds an Implicit return.
; Multiple implicit returns would result in an incorrectly calculated file size,
; causing the compiler to exit with an error.
; This should no longer happen so this code will test that it does not.
; This also demonstrates that if the last command before a label was a quit on a previous line,
; the FALLINTOFLST warning will still be issued.
; more at https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1773
start
	d  q
	.s b=1
label1(x) ; First fall through here.
	d  q
	. s b=2
label2(x)
	s b=3
	q
