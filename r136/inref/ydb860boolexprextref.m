;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

; Note: Below are various test cases that failed during fuzz testing. No pattern otherwise to these test cases.

	lock +[(0!^|"mumps.gld"|a)]x
	lock +[($get(^a(3))!$get(^|"mumps.gld"|a(3)))
	lock ^[(($Test&($ZAHandle(@iTRUE)]$ZAHandle(@iTRUE@(1)))!$Test)&^TRUE&($$RetNot(((((@iFALSE@($$Always1)[(1'>$Order(^TRUE(1),-1)))[$$RetNot($$Always0))>$$Always0)'>1))'[(0']]$$Always1))
	lock +[($Test!(1'=($Test'=^TRUE))!$Test!$$RetNot($Order(@^iTRUE@(2),-1)))
	lock +[(^TRUE!$Test!$$RetNot($Order(@^iTRUE@(2),-1)))
	lock +[(^TRUE!$$RetNot($Order(@^iTRUE@(2))))]
	lock +[(^TRUE!$$x($Order(^iTRUE(2))))]
	lock ^[(+aZYISSQLNULL(second)!^y(+c),+^z(d)
	lock +[(^x!$Order(^y(1)))]
	set ^[(0!^x(1)]
	quit

