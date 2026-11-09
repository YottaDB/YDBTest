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
ydb1375	; Check that a STACKCRIT error inside nested triggers leaves the symbol table of the caller unchanged
	; Run trigger code of different sizes, so the STACKCRIT error occurs at different points in the trigger invocation.
	; After each size, use indirection (which looks the variable name up in the current symbol table) to check that
	; the local variable "top" is still visible.
	set top=1,bad=""
	for i=0:1:200 do size(i) if '$data(@"top") set bad=i quit
	if ""=bad write "PASS : $data(@""top"")=1 after the trigger errors for all trigger code sizes",!
	else  write "FAIL : $data(@""top"")=0 after the trigger errors with trigger code size ",bad,", expected 1",!
	quit
size(n)	; Replace the trigger on ^c with one whose code has "n" more SET commands, then set ^c twice
	new k,s,x
	set s="" for k=1:1:n set s=s_" set v"_k_"=1"
	set x=$ztrigger("item","-*"),x=$ztrigger("item","+^c -command=S -xecute=""set ^c=$ztvalue+1"_s_"""")
	do try,try
	quit
try	; Set ^c, whose trigger sets ^c again, until the nested triggers fail with a STACKCRIT error
	new $etrap
	set $etrap="set $ecode="""" quit"
	set ^c=1
	quit
