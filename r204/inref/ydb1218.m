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

TEST1
	do
	. w "in do",!
SUM(x,y)
	s res=x+y
	w res,!
TEST2
	do
	. s x=1
SUM2(x,y)
	s res=x+y
	w res,!
