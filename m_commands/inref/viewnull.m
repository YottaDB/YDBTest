;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
viewnull	; view null subs for local variables
nolvnull;
	set $ztrap="goto incrtrap"
	write "view ""NOLVNULLSUBS""",!
	view "NOLVNULLSUBS"
	set abcdefghi0123456789012345678901("")=31		; should issue YDB-E-LVNULLSUBS error
	set abcdefghi0123456789012345678901(1)="xx312"
	set abcdefghi0123456789012345678901(1,"",2)=3123	; should issue YDB-E-LVNULLSUBS error
	write !,"-----> zwrite NOLVNULLSUBS 1 <------",!
	zwrite  write !
	set abcdefgh("")=1	; should issue YDB-E-LVNULLSUBS error
	set abcdefgh(1)="xx12"
	set abcdefgh(1,"",2)=123	; should issue YDB-E-LVNULLSUBS error
	write !,"-----> zwrite NOLVNULLSUBS 2 <------",!
	zwrite  write !
	set abcdefghi("")=91	; should issue YDB-E-LVNULLSUBS error
	set abcdefghi(1)="xx912"
	set abcdefghi(1,"",2)=9123	; should issue YDB-E-LVNULLSUBS error
	write !,"-----> zwrite NOLVNULLSUBS 3 <------",!
	zwrite  write !
	;test indirection
	set len=7,var="var"
	for i=4:1:len set n=i#10 set var=var_n
	set @var@("")="var"_len	; should issue YDB-E-LVNULLSUBS error
	;
	set len=8,var="var"
	for i=4:1:len set n=i#10 set var=var_n
	set @var@("")="var"_len	; should issue YDB-E-LVNULLSUBS error
	;
	set len=9,var="var"
	for i=4:1:len set n=i#10 set var=var_n
	set @var@("")="var"_len	; should issue YDB-E-LVNULLSUBS error
	;
	set len=31,var="var"
	for i=4:1:len set n=i#10 set var=var_n
	set @var@("")="var"_len	; should issue YDB-E-LVNULLSUBS error
	;
	write !,"-----> zwrite NOLVNULLSUBS 4 <------",!
	zwrite  write !
	quit
lvnull	;
	write "view ""LVNULLSUBS""",!
	set lvnullsubs="LVNULLSUBS"
	view lvnullsubs
	set abcdefgh("")=1
	set abcdefgh(1)=12
	set abcdefgh(1,"",2)=123
	write !,"-----> zwrite LVNULLSUBS 1 <------",!
	zwrite  write !
	set abcdefghi("")=91
	set abcdefghi(1)=912
	set abcdefghi(1,"",2)=9123
	write !,"-----> zwrite LVNULLSUBS 2 <------",!
	zwrite  write !
	set abcdefghi0123456789012345678901("")=31
	set abcdefghi0123456789012345678901(1)=312
	set abcdefghi0123456789012345678901(1,"",2)=3123
	write !,"-----> zwrite LVNULLSUBS 3 <------",!
	zwrite  write !
	;test indirection
	for len=7,8,9,31 do
	. set var="var"
	. for i=4:1:len do
	. . set n=i#10
	. . set var=var_n
	. set @var@("")="var"_len
	write !,"-----> zwrite LVNULLSUBS 4 <------",!
	zwrite  write !
	quit
incrtrap; ------------------------------------------------------------------------------------------
	;   Error handler. Prints current error and continues processing from the next M-line
	; ------------------------------------------------------------------------------------------
	if $tlevel trollback
	new savestat,mystat,prog,line,newprog
	set savestat=$zstatus
	set mystat=$P(savestat,",",2,100)
	set prog=$P($zstatus,",",2,2)
	set line=$P($P(prog,"+",2,2),"^",1,1)
	set line=line+1
	set newprog=$P(prog,"+",1)_"+"_line_"^"_$P(prog,"^",2,3)
	write "--> ERROR (expected) : $ZSTATUS=",mystat,!
	kill mystat,prog,line
	set newprog=$zlevel_":"_newprog
	zgoto @newprog
