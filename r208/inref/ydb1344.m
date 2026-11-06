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
; Helper routines for the r208/emit_rterror-ydb1344 subtest
ydb1344	;
	quit

gen	; Create the routines that the subtest compiles. Line 3 of each has an invalid special variable or function name
	; (a compile time warning) followed by another syntax error.
	new terms,i
	do write("ydb1344a"," w $length($zbar x")
	set terms="a(1)" for i=2:1:128 set terms=terms_"_"",""_a("_i_")"
	do write("ydb1344b"," w $zfoo,"_terms)
	do write("ydb1344c"," w $zbar(1)+$length(")
	do write("ydb1344d"," w $length($zbar x")
	do write("ydb1344e"," w $zbar")
	quit

write(rtn,line3)	; Write routine rtn.m whose line 3 is line3, with lines 2 and 4 that run and report it
	new file
	set file=rtn_".m"
	open file:newversion
	use file
	write rtn,!," write ""line 2 runs"",! set a=1 for i=1:1:128 set a(i)=i",!,line3,!," write ""line 4 runs"",!",!," quit",!
	close file
	quit

run(rtn,expect)	; DO ^rtn and check that line 3 issues the error expect
	new $etrap,lvl,zs
	set lvl=$zlevel,zs=""
	set $etrap="set zs=$zstatus,$ecode="""" zgoto "_lvl_":done^ydb1344"
	do @("^"_rtn)
done	if ""=zs write "FAIL : ^",rtn," did not issue an error",! quit
	write $select(zs[(",%YDB-E-"_expect_","):"PASS",1:"FAIL"),": line 3 of ^",rtn," issues ",$piece($piece(zs,",",3),"-",3),!
	quit
