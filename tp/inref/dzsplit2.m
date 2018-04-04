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
DZSPLIT2 ; ; ; test for PUTFAIL MP
	;
;requires a database with a block size of 2048
; Keep appending records to a zero-level directory block
; until it splits.
;
; Produced the following error message prior to V3.1-6a:
;  %YDB-E-GVPUTFAIL, Global variable put failed. Failure code: MP
;                  At M source location +24^DZSPLIT2
; ...followed by a hang upon exiting GT.M
;
	n (act)
	i '$d(act) n act s act="w var,"" = "",@var,!"
	v "gdscert":1
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s zeros="0000000"
	f i=1:1:195 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s @var="A"_i_" "_X
	h 1
	ts
	s ^B=1
	s ^A0000196="A196 "_X
	s ^A0000197="A197 "_X
	s ^A0000198="A198 "_X
	s ^A0000199="A199 "_X
	s ^A0000200="A200 "_X
	s ^A0000201="A201 "_X
	tc
	f i=1:1:201 Do
	. s var="^A"_$E(zeros,$L(i),6)_i
	. s cmp="A"_i_" "_X
	. i @var'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
