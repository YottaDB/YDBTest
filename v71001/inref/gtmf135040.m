;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Note that the gtmf135040 label is largely copied from the gtm8182
; label of v63003/inref/gtm8182.m. Similarly, getPaths is largely copied
; directly from the same routine. Finally, replmatch is modeled on
; the testPool label of that routine.

gtmf135040 ;
	do getPaths

	write "# Update the INST1 DB",!
	set ^x=1
	write "# Update the INST3 DB with an extended reference",!
	set ^|INST3gbldir|a=2

	write "# Switch to INST3 gbldir",!
	set $zgbldir=INST3gbldir

	write "# Update the INST3 DB",!
	set ^y=3
	write "# Update the INST1 DB with an extended reference",!
	set ^|INST1gbldir|b=4

	write "# Switch back to INST1 gbldir",!
	set $zgbldir=INST1gbldir

	write "# Show the initial JNLPOOL, i.e. INST1",!
	set initial=$view("JNLPOOL","")
	write initial,!
	write "# Show the JNLPOOL after the initial pool, i.e. INST3:",!
	set after=$view("JNLPOOL",initial)
	write after,!
	write "# Show the JNLPOOL after the second pool, i.e. """":",!
	set final=$view("JNLPOOL",after)
	write final,!

	quit

reversed ;
	do getPaths

	write "# Switch to INST3 gbldir",!
	set $zgbldir=INST3gbldir
	write "# Update the INST3 DB",!
	set ^x=1
	write "# Update the INST1 DB with an extended reference",!
	set ^|INST1gbldir|a=2

	write "# Switch to INST1 gbldir",!
	set $zgbldir=INST1gbldir

	write "# Update the INST1 DB",!
	set ^y=3
	write "# Update the INST3 DB with an extended reference",!
	set ^|INST3gbldir|b=4

	write "# Switch back to INST3 gbldir",!
	set $zgbldir=INST3gbldir

	write "# Show the initial JNLPOOL, i.e. INST3",!
	set initial=$view("JNLPOOL","")
	write initial,!
	write "# Show the JNLPOOL after the initial pool, i.e. INST1:",!
	set after=$view("JNLPOOL",initial)
	write after,!
	write "# Show the JNLPOOL after the second pool, i.e. """":",!
	set final=$view("JNLPOOL",after)
	write final,!

	quit

single ;
	do getPaths

	write "# Update the INST1 DB",!
	set ^x=1
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	write "# Switch to INST3 gbldir",!
	set $zgbldir=INST3gbldir

	write "# Update the INST3 DB",!
	set ^y=3
	write "# Show the current JNLPOOL, i.e. INST3",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	write "# Switch back to INST1 gbldir",!
	set $zgbldir=INST1gbldir
	write "# Update the INST1 DB",!
	set ^x=2
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	quit

noupdate ;
	do getPaths

	write "# Update the INST1 DB",!
	set ^x=1
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	write "# Switch to INST3 gbldir",!
	set $zgbldir=INST3gbldir

	write "# Do NOT update the DB using the INST3 gbldir",!
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	write "# Switch back to INST1 gbldir",!
	set $zgbldir=INST1gbldir
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	quit

erefswitch ;
	do getPaths

	write "# Update the INST1 DB",!
	set ^x=1
	write "# Show the current JNLPOOL, i.e. INST1",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	write "# Update the INST3 DB with an extended reference",!
	set ^|INST3gbldir|a=2

	write "# Show the current JNLPOOL, i.e. INST3",!
	set curpool=$view("JNLPOOL")
	write curpool,!

	quit

emptystr ;
	write $view("JNLPOOL",""),!
	quit

emptystrattached ;
	set ^x=1
	write $view("JNLPOOL",""),!
	quit

nomatch ;
	write $view("JNLPOOL","NOTAFILENAME"),!
	quit

getPaths ;
	set INST1path=$ztrnlnm("path_INST1","","","","","VALUE")
	set INST1gbldir=INST1path_"/mumps.gld"
	set INST1replfile=INST1path_"/mumps.repl"

	set INST3path=$ztrnlnm("path_INST3","","","","","VALUE")
	set INST3gbldir=INST3path_"/mumps.gld"
	set INST3replfile=INST3path_"/mumps.repl"

	quit
