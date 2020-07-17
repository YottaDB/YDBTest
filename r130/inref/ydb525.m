;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This tests for the presence of bug ydb525 which involves $io incorrectly
; being set to $principal after a SILENT^%RSEL. The test verifies that $io
; is correct both before and after the SILENT^%RSEL.

	set file="filename.txt"
	open file
	write "# verify that $io is correct before the SILENT^%RSEL",!
	use file ; $io should be filename after use
	set io=$io
	use $principal
	write io,!
	use file

	do SILENT^%RSEL("XU*","OBJ") ; trigger the bug

	set io=$io
	use $principal
	write "# verify that $io is correct after the SILENT^%RSEL",!
	write "# should print filename.txt but will print $principal if bug is present",!
	write io,!

; close the file
	close file:delete
