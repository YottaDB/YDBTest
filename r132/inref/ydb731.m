;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb731	;
	; YDB#731 : Test $VIEW("WORDEXP")
	;
	write "# Test unbalanced left paren issues WRDE_BADCHAR error",!
	do wordexp("(")
	write "# Test unbalanced right paren issues WRDE_BADCHAR error",!
	do wordexp(")")
	write "# Test unbalanced left flower brace issues WRDE_BADCHAR error",!
	do wordexp("{")
	write "# Test unbalanced right flower brace issues WRDE_BADCHAR error",!
	do wordexp("}")
	write "# Test unbalanced single-quote issues WRDE_SYNTAX error",!
	do wordexp("'")
	write "# Test unbalanced double-quote issues WRDE_SYNTAX error",!
	do wordexp("""")
	; Note that WRDE_BADVAL and WRDE_CMDSUB are impossible due to the way wordexp() is invoked in op_fnview.c
	; Note that WRDE_NOSPACE error is not easily testable as it requires an out-of-memory condition.
	write "# Test ~ expansion works without errors",!
	do wordexp("~")
	write "# Test $ expansion works without errors",!
	do wordexp("$envSpcfc")
	write "# Test repeated calls work fine",!
	for i=1:1:3 do wordexp("abcd")
	for i=1:1:3 do wordexp("abcd ~ $envSpcfc efgh")
	write "# Test input and output string lengths ranging from 0 to 1Mb. Verify MAXSTRLEN error as appropriate",!
	new str,len,i,input,output
	set str="$envSpcfc "
	set len=$zlength(str)
	for i=1:1:20 do
	. set input="" for j=1:1:(2**i)/10 set input=input_str
	. write "i = ",i," : $zlength(input) = ",$zlength(input)
	. set output=$VIEW("WORDEXP",input)
	. write " : $zlength(output) = ",$zlength(output),!
	quit

wordexp(str)
	new xstr
	set $etrap="zwrite $zstatus set $ecode="""""	; needed to move on even in case of errors
	;
	set xstr="write $VIEW(""WORDEXP"","_$zwrite(str)_")"
	write xstr," : Output = ["
	xecute xstr
	write "]",!
	quit

