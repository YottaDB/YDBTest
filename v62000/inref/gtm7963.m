;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7963	;
	set $etrap="do etr"
	set x("a")="a"
	set x("b")="b"
	do @$zcmdline
	quit
	;
test1	;
	if $incr(x("ac",undefined))
	quit
	;
test2	;
	set x("ab",1,2,3,4,5,6,7,8,9,undefined)=""
	quit
	;
test3	;
	for x("ab",undefined)=1:1:10  write "abcd",!
	quit
	;
test4	;
	merge y(1)=x
	merge x("ab",undefined)=y
	quit
	;
test5	;
	read x("ab",undefined)
	quit
	;
test6	;
	zshow "*":x("ab",undefined)
	quit
	;
test7	;
	if $incr(@"x(""ac"",undefined)")
	quit
	;
test8	;
	set @"x(""ab"",1,2,3,4,5,6,7,8,9,undefined)"=""
	quit
	;
test9	;
	for @"x(""ab"",undefined)"=1:1:10  write "abcd",!
	quit
	;
test10	;
	merge y(1)=x
	merge @"x(""ab"",undefined)"=y
	quit
	;
test11	;
	read @"x(""ab"",undefined)"
	quit
	;
test12	;
	zshow "*":@"x(""ab"",undefined)"
	quit
	;
etr	;
	write "$ZSTATUS=",$zstatus,!
	zwrite x
	set prevsubs="",subs=""
	for  set subs=$order(x(prevsubs))  quit:subs=""  write "$order(x(""",prevsubs,"""))=""",subs,"""",! set prevsubs=subs
	set str="x("""")",prevstr=str for  set str=$query(@prevstr) quit:""=str  write "$query(",prevstr,")=",str,! set prevstr=str
	set $ecode=""
	quit
