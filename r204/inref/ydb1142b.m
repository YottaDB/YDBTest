;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                              ;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.      ;
; All rights reserved.                                         ;
;                                                              ;
;      This source code contains the intellectual property     ;
;      of its copyright holder(s), and is made available       ;
;      under a license.  If you do not know the terms of       ;
;      the license, please stop and do not read further.       ;
;                                                              ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test for assert failure that would happen when you had
; an indented command on a formallist label line.
; The assert statement was fixed in a different commit.
; gitlab MR link https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1783/commits
; Also tests that the changes to adding an implicit quit do not cause any problems in this case.
; A syntax error is still expected as there should not be
; an indented command on a formallists label line in mumps.
	. do
LABLE(x) . w "Test"
