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
DZSPLIT1 ; ; ; test from getfail IIII
	;
;requires a database with a block size of 2048
; Keep adding record to the beginning of a pre-existing
; zero-level directory block until it splits.
;
; Produced the following error message prior to V3.1-6a:
;  %YDB-E-GVGETFAIL, Global variable retrieval failed. Failure code: IIII,
;  -GTM-I-GVIS, Global variable : ^A0000002
;  At M source location +22^DZSPLIT1
;
;
	n (act)
	i '$d(act) n act s act="w variable90123456789012345678901,"" = "",@variable90123456789012345678901,!"
	v "gdscert":1
	s cnt=0
	s X="1234567890"
	s X100=X_X_X_X_X_X_X_X_X_X
	s X1000=X100_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s X1900=X1000_X100_X100_X100_X100_X100_X100_X100_X100_X100
	s zeros="0000000"
	s top=202
	f i=top:-1:3 Do
	. set variable90123456789012345678901="^A"_$E(zeros,$L(i),6)_i
	. set variable9012345="^someothervalue"
	. set @variable90123456789012345678901="A"_i_" "_X
	ts
	s ^A0000002="A2 "_X
	s ^A0000001="A1 "_X
	tc
	f i=1:1:top Do
	. set variable90123456789012345678901="^A"_$E(zeros,$L(i),6)_i
	. set variable9012345="^SomeOtherGlobal"
	. set cmp="A"_i_" "_X
	. if @variable90123456789012345678901'=cmp s cnt=cnt+1 x act
	w !,$s(cnt:"FAIL",1:"PASS")," from ",$t(+0)
	q
