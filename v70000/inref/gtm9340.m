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
	write "#",!
	write "# Set POOLLIMIT to 0 so we have a predictable starting point (using 31 byte region name here)",!
	write "Executing: VIEW ""POOLLIMIT"":""REGNAME890123456789012345678901,DEFAULT"":0",!
	view "POOLLIMIT":"REGNAME890123456789012345678901,DEFAULT":0
	write "Show current values of region POOLLIMIT:",!
	write "POOLLIMIT on REGNAME890123456789012345678901: ",$view("POOLLIMIT","REGNAME890123456789012345678901"),!
	write "POOLLIMIT on DEFAULT:                         ",$view("POOLLIMIT","DEFAULT"),!
	write "#",!
	write "# Specify an extra character on the region name (32nd character) - should truncate and work correctly.",!
	write "# For reference, the actual region name is REGNAME890123456789012345678901 (no '2' on the end).",!
	write "# Also specify two region names as that is supposed to work. Expect no errors",!
	write "# Executing: VIEW ""POOLLIMIT"":""REGNAME8901234567890123456789012,DEFAULT"":512",!
	view "POOLLIMIT":"REGNAME8901234567890123456789012,DEFAULT":512
	write !
	write "# Now try a $VIEW function with the same input - expect VIEWREGLIST error",!
	write "# Executing: WRITE $VIEW(""POOLLIMIT"",""REGNAME8901234567890123456789012,DEFAULT"")",!
	do expecterr("VIEWREGLIST","write $view(""POOLLIMIT"",""REGNAME8901234567890123456789012,DEFAULT"")")
	write !
	write "# Display the POOLLIMIT value AFTER the VIEW POOLLIMIT cmd for each of our regions - expect success (both return 512 values - no error)",!
	write "# Executing: WRITE $VIEW(""POOLLIMIT"",""REGNAME8901234567890123456789012"")",!
	write $view("POOLLIMIT","REGNAME8901234567890123456789012"),!
	write "# Executing: WRITE $VIEW(""POOLLIMIT"",""DEFAULT"")",!
	write $view("POOLLIMIT","DEFAULT"),!
	write !
	write "# Attempt both VIEW command and $VIEW function referencing a too-long name of a non-existent region (expect NOREGION error)",!
	write "# Executing: VIEW ""POOLLIMIT:regname8901234567890123456789012""",!
	do expecterr("NOREGION","view ""POOLLIMIT"":""REG45678901234567890123456789012"":25")
	write "# Executing: WRITE $VIEW(""POOLLIMIT"",""REG45678901234567890123456789012"")",!
	do expecterr("NOREGION","write $view(""POOLLIMIT"",""REG45678901234567890123456789012"")")
	quit

;
; Execute specified command and expect to get error
;
expecterr(errname,command)
	new $etrap,goterrname
	set goterrname=0
	set $etrap="do goterr"
	xecute command
	do:0=goterrname
	. write "FAIL -- did not get expected error '",errname,"'",!
	quit

;
; Got an error - verify it is the one we are expecting
;
goterr
	if $zstatus'[("-"_errname_",") do  zhalt 1
	. write "Unknown failure: ",$zstatus,!!
	. zshow "*"
	;
	; Got expected error, unwind it and return
	;
	write "Got expected error (",errname,") - ",$zstatus,!
	set goterrname=1
	set $ecode=""
	quit
