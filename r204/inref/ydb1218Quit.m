;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                              ;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.      ;
; All rights reserved.                                         ;
;                                                              ;
;      This source code contains the intellectual property     ;
;      of its copyright holder(s), and is made available       ;
;      under a license.  If you do not know the terms of       ;
;      the license, please stop and do not read further.       ;
;                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Test for implicit_quit-ydb1218.csh to test that implicit_quit warning is issued
; if the last line in the Do block is a quit line.
START
	w "Started ydb1218Quit.m",!
	DO
	. quit
CONTINUE(x)
	w "This should never happen",!
