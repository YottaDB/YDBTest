;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; This module contains entry points that are serially driven by ydb845.csh
	;
ydb840	;
	quit

test1	;
	write "## ------------------------------------------------------------------------",!
	write "## test1 : Test that LKE SHOW output is not garbled if subscripts are close to 255 bytes long",!
	write "## In the below output, a255 implies a sequence of 255 consecutive characters ""a"" etc.",!
	write "## ------------------------------------------------------------------------",!
	set $etrap="zwrite $zstatus halt"
	for i=249:1:256 do
	. set x=$translate($justify("a",i)," ","a")
	. write "### Run [lock x(x,""dummy"") where subscript [x] is of length ",i,"]",!
	. lock x(x,"dummy")
	. if i'=256 write "### Run [lke show]. Expect no garbled output",!
	. else      write "### Run [lke show]. Expect LOCKSUB2LONG error",!
	. zsystem "sh -c '$ydb_dist/lke show 2>&1' | grep -vE ""DEFAULT|LOCKSPACE|^\$"""
	quit

test2	;
	write "## ------------------------------------------------------------------------",!
	write "## test2 : Test that LKE SHOW output is not truncated for up to 30 ASCII subscripts each 255 bytes long",!
	write "## In the below output, a255 implies a sequence of 255 consecutive characters ""a""",!
	write "## ------------------------------------------------------------------------",!
	set x=$translate($justify("a",255)," ","a")
	set xstr="lock +x("
	for i=1:1:29 set xstr=xstr_"x,",ystr=xstr_"x)" xecute ystr
	zsystem "sh -c '$ydb_dist/lke show 2>&1' | grep -vE ""DEFAULT|LOCKSPACE|^\$"""
	quit

test3	;
	write "## ----------------------------------------------------------------------------",!
	write "## test3 : Test that LKE SHOW output is not truncated for up to 30 non-ASCII subscripts each 255 bytes long",!
	write "## In the below output, X126Y is actually a sequence of 126 X followed by 1 Y where",!
	write "##       X=$c(128)_""a""_",!
	write "##       Y=$c(128)_""a""",!
	write "## Similarly, X84Y is actually a sequence of 84 X followed by 1 Y",!
	write "## ----------------------------------------------------------------------------",!
	; $char(128)_"a" is 3 bytes long in UTF-8 mode and 2 bytes long in M mode. Calculate maxj accordingly
	; so total length of "x" never exceeds 255 bytes (as otherwise one would get a LOCKSUB2LONG error).
	set maxj=$select($ztrnlnm("ydb_chset")="UTF-8":85,1:127)
	set x="" for j=1:1:maxj set x=x_$char(128)_"a"
	set xstr="lock x("
	for j=1:1:29 set xstr=xstr_"x,"
	xecute xstr_"x)"
	zsystem "sh -c '$ydb_dist/lke show 2>&1' | grep -vE ""DEFAULT|LOCKSPACE|^\$"""
	quit

test4	;
	write "## ------------------------------------------------------------------------",!
	write "## test4 : Test of %YDB-E-MAXNRSUBSCRIPTS in case LOCK command has more than 30 subscripts",!
	write "## ------------------------------------------------------------------------",!
	; Use xecute to avoid compile-time MAXNRSUBSCRIPTS error
	set $etrap="zwrite $zstatus halt"
	set xstr="lock x(1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,1,2,3,4,5,6,7,8,9,10,11)"
	xecute xstr
	quit

