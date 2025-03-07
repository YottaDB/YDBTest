;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb1129	;
	; Code points from 55296 onwards for a bit are invalid in UTF-8 format. To keep the below test program simple,
	; we stop before then to generate random characters in this test. That should be good enough since it is more
	; than half of the valid Unicode code points. In M mode, we allow only up to 255 as any more generates the empty string.
	set maxcodepoint=$select($zchset="UTF-8":55295,1:255)
	set max=1+$random(2048)	; set random maximum string length generated in below test
				; do not keep it too high (can be as high as 1Mb) as the test then ends up
				; wasting time mostly doing stringpool garbage collection.
	set start=$horolog
	; Run test for a max of 15 seconds OR 100 iterations whichever comes first.
	for i=1:1:100 do  quit:expect'=actual  quit:$$^difftime($horolog,start)>15
	. set x=$$genstr	; generate random input string
	. set y=$$genstr	; generate random search string
	. set z=$$genstr	; generate random replace string
	. set actual=$translate(x,y,z)	; run $translate and note down actual result
	. set expect=$$compute(x,y,z)	; run a helper function to compute what expected result should be
	if expect'=actual do		; issue FAIL if actual is not same as expected. issue PASS otherwise.
	. write "TEST-E-FAIL : $translate() returned incorrect results",!
	. set ^max=max,^x=x,^y=y,^z=z,^expect=expect,^actual=actual	; record failing scenario in globals
	. zshow "s" zwrite x,y,z,expect,actual
	else  write "PASS : $translate() returned correct results AND had no GTMASSERT2 failures",!
	quit

genstr() ;
	new i,str,bytelen,totlen,maxlen
	set len=$random(max)
	set str="",totlen=0,maxlen=(2**20)
	for i=1:1:len do  quit:totlen>maxlen
	. set codepoint=$random(maxcodepoint)
	. set bytelen=$zlength($char(codepoint))
	. set totlen=totlen+bytelen
	. quit:totlen>maxlen
	. set str=str_$char(codepoint)
	quit str

compute(x,y,z);
	new i,len,ch,translate,newch,expect
	set len=$length(y)
	for i=1:1:len do
	. set ch=$extract(y,i)
	. quit:$data(translate(ch))
	. set translate(ch)=i
	set len=$length(x)
	set expect=""
	for i=1:1:len do
	. set ch=$extract(x,i)
	. if '$data(translate(ch)) set newch=ch
	. else  set newch=$extract(z,translate(ch))
	. set expect=expect_newch
	quit expect

; Below are test cases reported by Konstantin at https://gitlab.com/YottaDB/DB/YDB/-/issues/1129#description

init	;
	set qq1="...($$G^qW(""pIDo"")=$g(qARM(""Pars"",3)))||($$G^qW(""RcpIDo"")=$g(qARM(""Pars"",3)))||($$UserOrd^qW(1,249,,$e(qqc,1,9),,""($$G^qW(""""pIDo"""")=$g(qARM(""""Pars"""",3)))&&($$G^qW(""""DGID.249.Pr"""")=""""""$$G^qW(""DGID"")"""""")"")'="""")||(($$G^qW(""elnst"")=1)&&($$FastKey^qW(293,""pAN BLnumA"",,0,""Аннулирование_листа_нетрудоспособности~""_$$G^qW(""BLnum""),$e(qqc,1,7),,,""$$G^qW(""""186:pIDo"""")=$g(qARM(""""Pars"""",3))"")))"
	quit

testorig1;
	do init
	set qq2=$length($translate(qq1,$translate(qq1,"""")))
	quit

testorig2;
	do init
	set qq2=$translate(qq1,""""),qq2=$length($translate(qq1,qq2))
	quit

testorig3;
	do init
	set ^A=qq1
	set qq1=^A set qq2=$translate(qq1,""""),qq2=$length($translate(qq1,qq2))
	quit

