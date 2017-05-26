;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7760	;
	; Verify this long concatenation does not produce TMPSTOREMAX compilation errors with dynamic literals. The expression
	; is 0_$$f_0_$$f_..._0_$$f, which has 252 (beyond that, you get MAXARGCNT errors) operands and evaluates to "0101...01".
	; Normally, you only need 126 temps, for the result of each '$$f'. But with dynamic literals, you need a temp for each
	; '0' literal -- 252 temps total.
	;
	set $etrap="do etr"
	set n=126
	set chunk="0_$$f",value=chunk
	for i=2:1:n set value=value_"_"_chunk
	set file="longcon.m" open file use file
	write "longcon",!
	write " s x="_value,!
	write " zwr x",!
	write " q",!
	write "f()",!
	write " q 1",!
	close file
	write "Compiling without -dynamic_literals",!
	set $zcompile=""
	zcompile "longcon.m"
	do ^longcon
	write "Compiling with -dynamic_literals",!
	set $zcompile="-DYNAMIC_LITERALS"
	zcompile "longcon.m"
	do ^longcon
	quit

etr	;
	write $zstatus,!
	zshow "S"
	quit
