;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper script for the relinkctlfull test to ensure we have no memory or file descriptor leaks on RELINKCTLFULL error. A white-box
; has limited the number of autorelinkable routines per object directory to 100. So, fill that quota and continue for another 2,000
; times, making sure that no memory or file descriptors leak.
relinkctlfull
	set $etrap="set $ecode="""""
	set $zroutines=".*"
	; Duplicate this routine as x.
	if $&ydbposix.cp("relinkctlfull.o","x.o",.errno)
	; Fill up the relinkctl routine quota. We are not linking in the copied objects but merely ZRUPDATEing them to avoid a
	; linking error due to object and source files having different names.
	for i=1:1:100 do
	.	if $&ydbposix.cp("relinkctlfull.o","x"_i_".o",.errno)
	.	zrupdate @("""x"_i_".o""")
	; Have the $etrap go off once to have all necessary memory allocated.
	do
	.	do ^x
	set (curr,prev)=$zrealstor
	; Continue for another 2,000 iterations.
	for i=1:1:2000 do
	.	if (i#100=0) do
	.	.	; If the memory usage increased from the last 100 iterations, signal an error.
	.	.	set curr=$zrealstor
	.	.	write "i = ",i," : $zrealstor = ",curr,!
	.	.	write:($zstatus'["RELINKCTLFULL") "TEST-E-FAIL, $zstatus is something other than RELINKCTLFULL: "_$zstatus,!
	.	.	write:(curr>prev) "TEST-E-FAIL, Memory usage increased from "_prev_" to "_curr,!
	.	.	set prev=$zrealstor
	.	do ^x
	quit
