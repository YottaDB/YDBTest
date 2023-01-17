;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This routine builds a filename pointing to the current directory whose name along with the
; path and the base filename specified totals the given length in bytes. There are two arguments
; specified on the command line. Invocation is:
;
;    $ydb_dist/yottadb -run longfilename <reqlen> <baseFn>
;
; Where <reqlen> is the requested length of the filename including the path in the current directory
; (note file does not need to exist yet, this is just a generated name).
; And <baseFn> means basically the suffix of the generated name. So if the parms were 255 and
; "mumps.repl", we would generate a filename something like "<currentdir>xxxxxxx<..>xxxmumps.repl"
; where the number of x's in the name would depend on the length of the path.
;
	set reqLen=$zpiece($zcmdline," ",1)
	set fnBase=$zpiece($zcmdline," ",2)
	if (""=reqLen)!(""=fnBase) do
	. write "* Missing parameters - $ydb_dist/yottadb -run ",$text(+0)," <reqlen> <basefn>",!
	. zhalt 1
	set dir=$zparse(".")
	set len=$zlength(dir)+$zlength(fnBase)
	set $zpiece(file,"x",reqLen-len+1)=""
	set bigFn=dir_file_fnBase
	if reqLen'=$zlength(bigFn) do
	. write "* bigFn length expected to be ",reqLen," but instead is ",$zlength(bigFn),!
	. zhalt 1
	write bigFn,!
	quit
