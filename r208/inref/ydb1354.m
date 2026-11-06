;#################################################################
;#								#
;# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
;# All rights reserved.						#
;#								#
;#	This source code contains the intellectual property	#
;#	of its copyright holder(s), and is made available	#
;#	under a license.  If you do not know the terms of	#
;#	the license, please stop and do not read further.	#
;#								#
;#################################################################
;
; Cases for r208/zshowvtolcl_key-ydb1354 : ^%ZSHOWVTOLCL finds the "=" that ends the name of each local variable
; in ZSHOW "V" output, even when the value starts with a quote or a subscript contains "="
;
ydb1354
	quit
quote	; A string subscript and a string value
	do case("%GTM(""p"")=""""")
	do case("x(""a"")=""""""""")
	do case("x(1,""a"")=""v""")
	do case("x(""a"")=""b""_$C(0)")
	quit
equal	; A subscript contains "="
	do case("x(""a=b"")=1")
	do case("x(""="",""="")=""""")
	do case("x(""""""="")=2")
	quit
other	; Quotes or "=" elsewhere
	do case("x=""a=b""")
	do case("x(""a"")=""=""")
	do case("x("""""""")=1")
	do case("x(""p"")=""""""=""""""")
	quit
case(line)	; Restore "line" as the only ZSHOW "V" line in ^zv, then check that ZSHOW "V" shows the same line
	kill ^zv,^zw,^zr
	set ^zv("V",1)=line
	do restore
	if (1=^zr)&(line=$get(^zw("V",1)))&'$data(^zw("V",2)) write "PASS : ",line," is restored",! quit
	write "FAIL : ",line," is not restored; ^%ZSHOWVTOLCL returned ",^zr,!
	zwrite:$data(^zw) ^zw
	quit
restore	; Restore the locals in ^zv into a frame with no other locals, return the result in ^zr and ZSHOW "V" in ^zw
	new
	set ^zr=$$^%ZSHOWVTOLCL("^zv")
	zshow "V":^zw
	quit
random	; ZSHOW "V" of random local variables, then restore them, 1000 times
	new i,fail
	set fail=0
	for i=1:1:1000 do  quit:fail
	. kill ^zv,^zw,^zr
	. do randvars
	. do restore
	. if 1'=^zr set fail=1 write "FAIL : ^%ZSHOWVTOLCL returned ",^zr,!
	. else  if '$$same set fail=1 write "FAIL : ZSHOW ""V"" after the restore differs",!
	. if fail write "ZSHOW ""V"" before the restore :",! zwrite ^zv write "ZSHOW ""V"" after the restore :",! zwrite:$data(^zw) ^zw
	write:'fail "PASS : 1000 sets of random local variables are restored",!
	quit
randvars	; Set up to 4 random nodes of xv, with values and subscripts made of =, ", (, ), comma, a, 1 and space, then
	; ZSHOW "V" them to ^zv. About one value in 5 is up to 700 characters long, so that ZSHOW "V" splits most of
	; those into continuation nodes in a database with a record size of 256.
	new
	new k,sub
	for k=1:1:1+$random(4) set sub=$$randstr(5) do
	. if 0=$random(3) set xv=$$randstr(5) quit
	. if 0=$random(2) set xv(sub)=$$randstr($select($random(5):5,1:700)) quit
	. set xv(sub,$$randstr(5))=$$randstr(5)
	kill k,sub
	zshow "V":^zv
	quit
randstr(max)	; A random string of up to "max" characters
	new chars,len,str
	set chars="=""(),a1 ",str=""
	for len=1:1:$random(max+1) set str=str_$extract(chars,1+$random($length(chars)))
	quit str
same()	; Whether ^zv and ^zw have the same nodes and values
	new a,b
	set a="^zv",b="^zw"
	for  set a=$query(@a),b=$query(@b) quit:(""=a)!(""=b)  quit:$extract(a,4,$length(a))'=$extract(b,4,$length(b))  quit:@a'=@b
	quit (""=a)&(""=b)
