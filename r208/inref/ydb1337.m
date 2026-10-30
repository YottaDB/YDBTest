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
; Helper M program used by the r208/zpeek_len-ydb1337 subtest. Each label checks the result of one $ZPEEK() call and
; prints PASS or WRONG.
;
len100000	; A first argument of 100000 bytes with no colon
	do check($translate($justify("",100000)," ","A"),"100000 bytes","length")
	quit
len64	; A first argument of 64 bytes with no colon, 1 more than the maximum of 63
	do check($translate($justify("",64)," ","A"),"64 bytes","length")
	quit
len63	; A first argument of 63 bytes with no colon, not a valid mnemonic
	do check($translate($justify("",63)," ","A"),"63 bytes","mnemonic type")
	quit
len32	; A first argument of 32 bytes with no colon, not a valid mnemonic
	do check($translate($justify("",32)," ","A"),"32 bytes","mnemonic type")
	quit
arglong	; A valid mnemonic whose argument (a region name) takes the first argument to 64 bytes
	do check("GDRREG:"_$translate($justify("",57)," ","A"),"64 bytes (GDRREG: and a region name)","length")
	quit
valid	; A valid mnemonic and argument. The first field of the region structure is the length of the region name.
	new x
	set x=$zpeek("GDRREG:DEFAULT",0,2,"U")
	if 7=x write "PASS : $ZPEEK(""GDRREG:DEFAULT"",0,2,""U"") returned 7, the length of the region name DEFAULT",! quit
	write "WRONG : $ZPEEK(""GDRREG:DEFAULT"",0,2,""U"") returned [",x,"], expected 7, the length of the region name DEFAULT",!
	quit
gdrreg31	; GDRREG with a region name of 31 bytes (the maximum). The first field of the region structure is the length of the
	; region name.
	new x
	set x=$zpeek("GDRREG:RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",0,2,"U")
	if 31=x write "PASS : $ZPEEK(""GDRREG:<31-byte region name>"",0,2,""U"") returned 31, the length of the region name",! quit
	write "WRONG : $ZPEEK(""GDRREG:<31-byte region name>"",0,2,""U"") returned [",x,"], expected 31",!
	quit
critreg31	; CRITREG with a region name of 31 bytes, a first argument of 39 bytes, the longest valid first argument
	new x
	set x=$zpeek("CRITREG:RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA",0,2,"U")
	if x?1.N write "PASS : $ZPEEK(""CRITREG:<31-byte region name>"",0,2,""U"") returned a number",! quit
	write "WRONG : $ZPEEK(""CRITREG:<31-byte region name>"",0,2,""U"") returned [",x,"], expected a number",!
	quit
gdrreg32	; GDRREG with a region name of 32 bytes, 1 more than the maximum
	do check("GDRREG:RAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA","39 bytes (GDRREG: and a 32-byte region name)","mnemonic argument")
	quit
check(arg,desc,expect)	; Call $ZPEEK(arg,0,0) and check that it issues BADZPEEKARG with the parameter named by "expect"
	new err,want
	set err=""
	do peek(arg,.err)
	set want="%YDB-E-BADZPEEKARG, Missing, invalid or surplus "_expect_" parameter for $ZPEEK()"
	if $piece(err,",",3,99)=want write "PASS : a first argument of ",desc," issued ",want,! quit
	write "WRONG : a first argument of ",desc," issued [",$piece(err,",",3,99),"], expected ",want,!
	quit
peek(arg,err)	; Call $ZPEEK(arg,0,0) and return its error in "err"
	new $etrap,x
	set $etrap="set err=$zstatus,$ecode="""" quit"
	set x=$zpeek(arg,0,0)
	quit
