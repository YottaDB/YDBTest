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

	; D9D08-002352 $Q() fails on nodes with "" in last subscript
d002352
	s a("")=0
	s a(1,2,4)=1
	s a(1,2,"",3)=2
	s a(1,3,"")=3
	s a(1,3,2)=4
	s a(1,3,"a")=5
	s a("test")=6
	s ref="a"
	for i=1:1:10 do  Q:ref=""
	. s ref=$q(@ref)
	. w "Next var is ",ref,!

