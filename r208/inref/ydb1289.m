;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1289 : MUPIP LOAD must load any number of $ze(...) records in a ZWR file.
;
; Record i (from 1 to 3,000,000) of the file sets the first character of ^a(i#1000+1) to the letter
; $char(97+(i#26)). Each node is set 3000 times, and the last record that sets it determines its
; value, so check^ydb1289 can derive the value each of the 1000 nodes must end up with.
;
ydb1289	;
	write "Run one label at a time. See mupip_load_ze-ydb1289.csh",!
	quit
	;
gen	; Write the ZWR file named in $zcmdline
	new file,i,n,buf
	set file=$zcmdline,n=$$nrecs
	open file:newversion
	use file
	write "YDB#1289 $ze() records",!,"01-OCT-2026  12:00:00 ZWR",!
	; Write 1000 records at a time, separated by $char(10), to keep the file writes few. The "!" after
	; each group resets $X, so the device never inserts a newline of its own at WIDTH.
	set buf=""
	for i=1:1:n do
	. set buf=buf_$select(""=buf:"",1:$char(10))_"$ze(^a("_(i#1000+1)_"),0,1)="""_$char(97+(i#26))_""""
	. if 0=(i#1000) write buf,!  set buf=""
	if ""'=buf write buf,!
	close file
	quit
	;
check	; Check that ^a(1) to ^a(1000) hold the value of the last record that set each of them
	new i,j,n,exp,errs,cnt
	set n=$$nrecs
	for i=n-999:1:n set exp(i#1000+1)=$char(97+(i#26))
	set errs=0
	for j=1:1:1000 if $get(^a(j))'=exp(j) set errs=errs+1 if errs'>5 write "WRONG : ^a(",j,") is ",$zwrite($get(^a(j))),", expected ",$zwrite(exp(j)),!
	set cnt=0,j="" for  set j=$order(^a(j)) quit:""=j  set cnt=cnt+1
	if 1000'=cnt set errs=errs+1 write "WRONG : ^a has ",cnt," subscripts, expected 1000",!
	if 0=errs write "PASS : ^a has 1000 subscripts and each holds the value of the last record that set it",!
	quit
	;
nrecs()	quit 3000000
