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

ydb724	;
	set errors=0
	set delim="***********************************************************************************************"
	write delim,!
	write "Case 1: Verify whether numeric value passed as a literal or as computed value gets same transformation",!
	set a=$zatransform(123,0)
	set x=1,b=$zatransform(123*x,0)
	if a=b write "** Success - both values same: ",$zwrite(a),!
	else  do
	. write "**** Failure - values differ - a: ",$zwrite(a),"  b: ",$zwrite(b),!
	. if $increment(errors)
	;
	write !,delim,!
	write "Case 2: Verify collation transformation happens even when processing strings irrespective of 4th argument",!
	write "        (treat numerics as strings) being 0 or 1",!
	set a=$zatransform("abcd",1,0,0)
	set b=$zatransform("abcd",1,0,1)
	if a=b write "** Success - both values same: ",$zwrite(a),!
	else  do
	. write "**** Failure - values differ - a: ",$zwrite(a),"  b: ",$zwrite(b),!
	. if $increment(errors)
	write !,delim,!
	write "ydb724 test ",$select(0=errors:"PASSED",1:"FAILED"),!
	quit
