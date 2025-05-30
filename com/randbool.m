;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; gen^randbool : generate count numbers of random boolean value of the given type
; 	gen^randbool 1 10
; 	randbool gen 1 10
; 	gen^randbool 0 3
; 	randbool gen 0 3
; check^randbool : convert the list of passed arguments to 0 or 1
;	check^randbool trUe 0 1 FALSE 100 trues
;	randbool check trUe 0 1 FALSE 100 trues
; GT.M considers non-zero integers OR case insensitive substrings of true/yes OR true.*/yes.* to be TRUE - Anything else is false
; while 1 is TRUE - 1.0 or +1 is FALSE
randbool	;
	set todo=$piece($ZCMDLINE," ",1)
	if todo="gen" do
	. set input=$piece($ZCMDLINE," ",2,$length($ZCMDLINE," "))
	. do gen
	if todo="check" do
	. set input=$piece($ZCMDLINE," ",2,$length($ZCMDLINE," "))
	. do check
	quit
gen	;
	set truelist="1,t,tr,tru,true,y,ye,yes,"
	set falselist="0,f,fa,fal,fals,false,n,no,1.0,+1,"
	set debugfile="randbool_strings.txt"
	open debugfile:append
	if '($data(input)) set input=$ZCMDLINE
	set type=$piece(input," ",1)
	set count=$piece(input," ",2)
	if (""=count) set count=1
	if (1=type)  do
	. set list=truelist
	else  do
	. set list=falselist
	set len=$length(list,",")
	for i=1:1:count do
	. ; pick a random string (randx) from the above list
	. set rand=$random(len)
	. set retx=$piece(list,",",rand)
	. if (""=retx)  do
	. . ; If retx is null (one of the elements in the list) ; set a random integer for true and a random string (excluding true/yes) for false
	. . if (1=type) set ret=1+$random(2147483646)
	. . ; setting an environment variable with a string having the characters { [ and ~ errors out
	. . if (0=type) for  set ret=$$^%RANDSTR(1+$random(10),"33:1:90,92:1:122,124:1:125","AP") quit:'$$istrue(ret)
	. else  do
	. . set retlen=$length(retx)
	. . ; randomly convert one char to upper case (xth character) - x is $r(2*length) to increase the probability of not changing the case
	. . set x=$random(2*retlen)
	. . set ret=$extract(retx,1,x)_$zconvert($extract(retx,x+1),"U")_$extract(retx,x+2,retlen)
	. use debugfile write $zdate($horolog,"DD-MON-YEAR 24:60:SS")_" : "_type_" : "_ret,!
	. use $PRINCIPAL write ret,!
	quit
check	;
	if '($data(input)) set input=$ZCMDLINE
	set inputs=$length(input," ")
	for i=1:1:inputs do
	. set inp=$piece(input," ",i)
	. write $$istrue(inp),!
	quit
istrue(input)	;
	set (true("y"),true("ye"),true("yes"),true("t"),true("tr"),true("tru"),true("true"))=1
	set x=$zconvert(input,"L")
	quit (((x?.N)&x)!($data(true(x))))
