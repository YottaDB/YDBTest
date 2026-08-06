ydb1249	;
	;################################################################
	;								#
	; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
	; All rights reserved.						#
	;								#
	;	This source code contains the intellectual property	#
	;	of its copyright holder(s), and is made available	#
	;	under a license.  If you do not know the terms of	#
	;	the license, please stop and do not read further.	#
	;								#
	;################################################################
	;
	; YDB#1249 : a trigger subscript specification with an open ended range has an
	; empty specification for the open side. Reading the definition back from ^#t
	; used to examine the first byte of that empty specification, which is one byte
	; past its end, and act on it when it happened to be a double quote.
	;
	do openright
	do openleft
	do bothopen
	do cycles
	quit
	;
openright	; open right side: fires at and above the left bound
	write !,"# +^x(sub1=2:) fires for subscripts 2 and above",!
	do load("+^x(sub1=2:) -commands=SET -xecute=""set ^y(sub1)=$ztvalue""")
	do fire
	quit
	;
openleft	; open left side: fires at and below the right bound
	write !,"# +^x(sub1=:3) fires for subscripts 3 and below",!
	do load("+^x(sub1=:3) -commands=SET -xecute=""set ^y(sub1)=$ztvalue""")
	do fire
	quit
	;
bothopen	; both sides open: equivalent to "*"
	write !,"# +^x(sub1=:) fires for every subscript",!
	do load("+^x(sub1=:) -commands=SET -xecute=""set ^y(sub1)=$ztvalue""")
	do fire
	quit
	;
cycles	; the reported symptom: KILL of the global with such a trigger defined
	new i,j,n
	set n=0
	for i=1:1:25 do
	. do load("+^x(sub1=2:) -commands=SET -xecute=""set ^y(sub1)=$ztvalue""")
	. do load("+^x -commands=KILL -xecute=""kill ^y""")
	. kill ^x
	. for j=1:1:5 set ^x(j)="v"_j
	. do killgbl(.n)
	. do clear
	write !,"# 25 define, fire and KILL cycles: ",n," error(s)",!
	quit
	;
killgbl(n)	; KILL the global; count any error rather than letting it stop the test
	new $etrap set $etrap="write ""#   "",$piece($zstatus,"","",3),! set n=n+1,$ecode="""" quit"
	kill ^x
	quit
	;
fire	; drive the loaded trigger over subscripts 1 through 4
	new i
	kill ^x,^y
	for i=1:1:4 set ^x(i)="v"_i
	zwrite ^y
	do clear
	quit
	;
load(trig)	; load one trigger definition
	new x
	set x=$ztrigger("item",trig)
	if 'x write "# FAILED to load: ",trig,!
	quit
	;
clear	; remove every trigger
	new x
	; "-^x" only matches a trigger defined as ^x with no subscripts, so it leaves
	; the subscripted ones in place; "-*" removes them all
	set x=$ztrigger("item","-*")
	kill ^x,^y
	quit
