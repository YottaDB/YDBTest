;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	;
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
	; ############################################################################
	; Continue for another 2,000 iterations. And detect if memory usage increases.
	; ############################################################################
	; Note down $zrealstor around iteration number 500 instead of before iteration 1 (like one would normally think).
	; This is because we have seen stp_gcol() allocate 0.3Mb somewhere between iterations 200 and 300
	; after the YDB#786 changes to rework stpg_sort() to use a faster sort algorithm (the previous slightly
	; slower stpg_sort() did not do this memory allocation and hence it was fine to note $zrealstor at iteration 1
	; in prior YottaDB builds). This stp_gcol() allocation is completely unrelated to the memory usage that this
	; tests wants to check and so allow for this by noting down the baseline memory usage a little down the for loop.
	for i=1:1:2000 do
	.	if (i#100=0) do
	.	.	; If the memory usage increased since we last noted it down at the 500th iteration, signal an error.
	.	.	set curr=$zrealstor
	.	.	do:i>500
	.	.	.	write "i = ",i," : $zrealstor = ",curr,!
	.	.	.	write:($zstatus'["RELINKCTLFULL") "TEST-E-FAIL, $zstatus is something other than RELINKCTLFULL: "_$zstatus,!
	.	.	.	write:(curr>prev) "TEST-E-FAIL, Memory usage increased from "_prev_" to "_curr,!
	.	.	set prev=$zrealstor
	.	do ^x
	quit
