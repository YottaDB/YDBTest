;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2006-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
basic;
	; xecute and zbreak action are same.
	write "Simple zbreak test starts",!
	set begline=2
	set maxline=14	; No comment line should be in between in the called routine from begline to maxline
	;
	set step=1
	write section,!
	write "Set break points",!
	for lineno=begline:1:maxline  do
	. zbreak zbbasic+lineno^zbbasicexec:"set zbbasic(""ｂｙｔｅ_後漢書_？？_4"","_lineno_")=$get(zbbasic(""ｂｙｔｅ_後漢書_？？_4"","_lineno_"))+1"
	write "After break points set: Show the break points and stack:",!  zshow "BS"
	;
	write section,!
	write "Test xecute",!
	for lineno=begline:1:maxline  do
	. xecute "set zbbasic(""ｂｙｔｅ_後漢書_？？_4"","_lineno_")=$get(zbbasic(""ｂｙｔｅ_後漢書_？？_4"","_lineno_"))+1"
	write "Verify xecute",!
	set xecutefailed=0
	for lineno=begline:1:maxline  do
	. if zbbasic("ｂｙｔｅ_後漢書_？？_4",lineno)'=step write "TEST-E-XECUTE Test Failed in xecute in step ",step," for lilneno: ",lineno,! set xecutefailed=1
	if (1=xecutefailed) zwr zbbasic
	;
	set step=2
	write section,!
	write "Test zbreak actions",!
	write "do zbbasic^zbbasicexec",!  do zbbasic^zbbasicexec
	;
	write "After zbreak actions: Show the break points and stack:",!  zshow "BS"
	write "Now verify data",!
	write "do verify^zbbasicexec",!  do verify^zbbasicexec
	set zbreakfailed=0
	for lineno=begline:1:maxline  do
	. if zbbasic("ｂｙｔｅ_後漢書_？？_4",lineno)'=step write "TEST-E-ZBREAK Test Failed in zbreak action in step ",step," for lineno: ",lineno,! set zbreakfailed=1
	if (1=zbreakfailed) zwr zbbasic
	;
	set step=3
	write section,!
	write "Set break points again",!
	for lineno=begline:1:maxline  do
	. set cmd(lineno)="set zbbasic(""ｂｙｔｅ_後漢書_？？_4"",""3bytevariable"","_lineno_")=$increment(zbbasic(""ｂｙｔｅ_後漢書_？？_4"","_lineno_"))"
	. zbreak zbbasic+lineno^zbbasicexec:cmd(lineno)
	;
	write "Test xecute cmd",!
	for lineno=begline:1:maxline  do
	. xecute cmd(lineno)
	write "Verify xecute cmd",!
	set xecutefailed=0
	for lineno=begline:1:maxline  do
	. if zbbasic("ｂｙｔｅ_後漢書_？？_4","3bytevariable",lineno)'=step write "TEST-E-XECUTE Test Failed in xecute action in step ",step," for lineno : ",lineno,!  set xecutefailed=1
	if (1=xecutefailed) zwrite zbbasic
	;
	set step=4
	write section,!
	write "Test zbreak actions again",!
	write "do zbbasic^zbbasicexec",!  do zbbasic^zbbasicexec
	;
	write "After second zbreak actions: Show the break points and stack:",!  zshow "BS"
	write "Now verify data",!
	write "do verify^zbbasicexec",!  do verify^zbbasicexec
	set zbreakfailed=0
	for lineno=begline:1:maxline  do
	. if zbbasic("ｂｙｔｅ_後漢書_？？_4","3bytevariable",lineno)'=step write "TEST-E-ZBREAK Test Failed in zbreak action in step ",step," for lineno: ",lineno,! set zbreakfailed=1
	if (1=zbreakfailed) zwrite zbbasic
	;
	write "Simple zbreak test ends...",!
	quit
testunicode	;
	write "This section is to trigger zbreak to do routine passing unicode string",!
	write "Will force a zbreak on executing next 2 lines",!
	write "Trigger zbreak",!
	write "zbreak triggered",!
	write "testunicode ends...",!
	quit
dounicode(inp)	; To test if unicode string is passed in do action of zbreak
	write "The string passed is : ",inp,!
;	write "The upper case of ",inp," is : ",$zconvert(s,"U"),!
	write "dounicode ends...",!
	quit
testdollartext	;
	write "This section is to test $text with unicode data",!
	; __UNICODE COMMENT_
	write "This is unicode ｂｙｔｅ_後漢書_？？_4 text",!
	; comment having ASCII and unicode - ｂｙｔｅ_後漢書_？？_4
	write "testdollartext ends...",!
	quit
dodollartext	; Have the same number of lines as testdollartext
	write "Test unicode data in $text",!
	write "checks the display of unicode comment",!
	write "and unicode text",!
	write ".. and both",!
	write "dodollartext ends...",!
	quit
