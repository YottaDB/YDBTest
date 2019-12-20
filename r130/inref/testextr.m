;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.  ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; The below routine confirms the presence and value of ^hello("one")="1".
; This is being used by ydb493.csh for upstream compatibility tests.
; Result: if ^hello is defined and equal to "1" writes "PASSED"
; 	  if ^hello is not defined routine results in an error
;	  if value is different expect an empty output
dbhasdata
	if ^hello("one")="1" write "PASSED"

