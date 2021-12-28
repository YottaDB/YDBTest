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

ydb828newbreak	;	Test NEW:0 or BREAK:0 followed by other commands in same M line does not SIG-11'
	quit

test1	;
	write "# test1 : NEW:0 : Expect LVUNDEF error"
	for   read w new:0  close:i j
	quit

test2	;
	write "# test2 : NEW:0 : Expect LVUNDEF error"
	new:0  close:i j
	quit

test3	;
	write "# test3 : NEW:0 : Expect LVUNDEF error"
	new:0  close i
	quit

test4	;
	write "# test4 : NEW:0 : Expect LVUNDEF error"
	new:0  close:i $test
	quit

test5	;
	write "# test5 : NEW:0 inside FOR loop : Expect LVUNDEF error"
	for i=1:1:10 new:0  close x
	quit

test6	;
	write "# test6 : BREAK:0 : Expect LVUNDEF error"
	break:0 x write y
	quit

test7	;
	write "# test7 : BREAK:0 inside FOR loop : Expect LVUNDEF error"
	for i=1:1:10 break:0 x close y
	quit

test8	;
	write "# test8 : NEW:0 : Expect 5 as output",!
	set x=5
	new:0  write x
	quit

test9	;
	write "# test9 : BREAK:0 : Expect 8 as output",!
	set y=8
	break:0 x write y
	quit

test10	;
	write "# test10 : NEW:0 inside FOR loop : Expect 555 as output",!
	set x=5
	for i=1:1:3 new:0  write x
	quit

test11	;
	write "# test11 : BREAK:0 inside FOR loop : Expect 888 as output",!
	set y=8
	for i=1:1:3  break:0 x write y
	quit

