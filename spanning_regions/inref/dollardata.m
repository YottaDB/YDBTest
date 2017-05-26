;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
dollardata	;
	set ^x=1
	w "Test  0 : $data(^x))     = ",$data(^x),!
	k ^x
	;
	set ^x(1)=1
	w "Test  1 : $data(^x))     = ",$data(^x),!
	w "Test  2 : $data(^x(1))   = ",$data(^x(1)),!
	k ^x(1)
	;
	set ^x(1,2)=1
	w "Test  3 : $data(^x))     = ",$data(^x),!
	w "Test  4 : $data(^x(1))   = ",$data(^x(1)),!
	w "Test  5 : $data(^x(1,2)) = ",$data(^x(1,2)),!
	k ^x(1,2)
	;
	set ^x(1,3)=1
	w "Test  6 : $data(^x))     = ",$data(^x),!
	w "Test  7 : $data(^x(1))   = ",$data(^x(1)),!
	w "Test  8 : $data(^x(1,3)) = ",$data(^x(1,3)),!
	k ^x(1,3)
	;
	set ^x(2)=1
	w "Test  9 : $data(^x))     = ",$data(^x),!
	w "Test 10 : $data(^x(1))   = ",$data(^x(1)),!
	w "Test 11 : $data(^x(1,3)) = ",$data(^x(1,3)),!
	w "Test 12 : $data(^x(2))   = ",$data(^x(2)),!
	w "Test 13 : $data(^x(2,3)) = ",$data(^x(2,3)),!
	k ^x(2)
	;
	set ^x(3)=1
	w "Test 14 : $data(^x))     = ",$data(^x),!
	w "Test 15 : $data(^x(1))   = ",$data(^x(1)),!
	w "Test 16 : $data(^x(1,3)) = ",$data(^x(1,3)),!
	w "Test 17 : $data(^x(3))   = ",$data(^x(3)),!
	w "Test 18 : $data(^x(3,3)) = ",$data(^x(3,3)),!
	k ^x(3)
	;
	set ^x(7)=1
	w "Test 19 : $data(^x)      = ",$data(^x),!
	w "Test 20 : $data(^x(1))   = ",$data(^x(1)),!
	w "Test 21 : $data(^x(7))   = ",$data(^x(7)),!
	k ^x(7)
	q
