;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains M code used by the ydb518 test to test call ins
; and external calls involving the new ydb_int64_t and ydb_uint64_t
; types.

cubeit(X)
	use 0
	write !,"M2, C-> M -> C -> M",!
	new num
	set num=X**3
	quit num

sqroot(num,root)
	use 0
	write !,"M1, C->M->C->M",!
	new p
	set root=0
	set num=$SELECT(num<0:-num,num=0:1,1:num)
	set root=$SELECT(num>1:num\1,1:1/num)
	set root=$EXTRACT(root,1,$LENGTH(root)+1\2) set:num'>1 root=1/root
	for p=1:1:6 Set root=num/root+root*.5
	write !,"Using ",$text(+0)," the root of ",num," is ",root
	write !,"Now <Set square=$&squarec(root)> will do external call to C",!
	set square=$&squarec(root)
	use 0
	write !,"External call routine ",$text(+0)," returning to the square of ",num," as ",square,!
	quit
