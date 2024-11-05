;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; GTM-9423 Verify MUPIP DUMPINFO recognizes the -FLUSH parameter
;
gtm9423
	set $etrap="zwrite $zstatus zshow ""*"" zhalt 1"
	write !
	write "# Part 1:",!
	write "# Verify that MUPIP DUMPFHEAD -FLUSH does the flush before it writes DUMPFHEAD info",!
	;
	; Note, we don't need to load anything in the database to make this work, we can flush the fileheader
	; of a freshly created database and it still flushes the file header.
	;
	write !
	write "# Run strace cmd: strace -o strace.outx $gtm_dist/mupip dumpfhead -reg DEFAULT -flush >& dumpfhead.out",!
	zsystem "strace -o strace.outx $gtm_dist/mupip dumpfhead -reg DEFAULT -flush >& dumpfhead.out"
	if 0'=$zsystem do
	. write !,"Error code ",$zsystem," from strace command - see dumpfhead.out for errors",!
	. zhalt 1
	write !
	write "# Run grep on the strace.outx file to find (in the order they occur):",!
	write "#  1. open() or openat() calls on mumps.dat",!
	write "#  2. pwrite64 calls (only done to DB) - show all of them",!
	write "#  3. write(1..) calls to write out DUMPFHEAD info",!!
	zsystem "$grep -E '(pwrite64|((open|openat).*mumps.dat"")|write\(1,)' strace.outx"
	if 0'=$zsystem do
	. write !,"Error code ",$zsystem," from grep command",!
	. zhalt 1
	;
	; Part 2
	;
	write !!
	write "# Part 2:",!!
	write "# Verify that the BUFFLUFAILED warning is raised when -FLUSH detects an IO error",!
	write !
	write "# Use DSE CRIT -SEIZE to grab crit in the region to hopefully force a flush error",!
	set pipe="dsepipe"
	open pipe:(command="$gtm_dist/dse")::"PIPE"
	use pipe
	write "crit -seize",!			; Seize crit in DEFAULT to cause BUFFLUFAILED
	read response
	write "  response: ",response,!
	use $p
	write !
	write "# Run MUPIP DUMPFHEAD -REG DEFAULT -FLUSH expecting a BUFFLUFAILED warning",!
	;
	; Note use type outx here to prevent BUFFLUFAILED from failing test
	;
	zsystem "$gtm_dist/mupip dumpfhead -reg ""DEFAULT"" -FLUSH >& dumpfhead2.outx"
	if 0'=$zsystem do
	. write !,"Error code ",$zsystem," from strace command - see dumpfhead2.outx for errors",!
	. zhalt 1
	use pipe
	write "crit -release",!
	close pipe
	use $p
	write !
	write "# Verify got a BUFFLUFAILED message:",!!
	zsystem "$grep BUFFLUFAILED dumpfhead2.outx"

	quit

