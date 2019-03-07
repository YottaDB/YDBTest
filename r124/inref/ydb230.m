;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
case12	;
	For i=1:1:3 Write $zsearch("ydb230_*.txt",$ZCMDLINE),!
	quit

case3	;
	For i=0:1:9  do
	.	For  set rand=$random(256) quit:'$DATA(randcheck(rand))
	.	set strNum(i)=rand  set randcheck(rand)=1
	set strNum(10)=-1
	set k=-1
	For i=0:1:10  do
	.	For j=1:1:3  do
	.	.	set gen($increment(k))="    Write $zsearch(""ydb230_*.txt"","_strNum(i)_")"

	set file="ydb230run.m"
	open file:(newversion)
	use file
	set ind=33
	For i=1:1:33  do
	.	set rand=$random(ind)
	.	set stream=""" Stream "_$piece($piece(gen(rand),",",2),")",1)_""",!"
	.	write gen(rand)_"_"_stream,!
	.	set gen(rand)=gen($increment(ind,-1))
	close file

	set tfile="randVal.txt"
	open tfile:(newversion)
	set randNumStr="-1"
	For i=0:1:9  do
	.	set randNumStr=randNumStr_" "_strNum(i)
	use tfile
	write randNumStr
	close tfile
	quit
