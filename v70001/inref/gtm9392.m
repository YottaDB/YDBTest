;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm9392	;
	write "# Run [view ""NOISOLATION"":""+^a""] before opening the database file",!
	view "noisolation":"+^a"
	write "# Run [write $view(""NOISOLATION"",""^a"")]. Expect output of 1.",!
	write $view("noisolation","^a"),!
	write "# Open database file by running [set x=$get(^a)]",!
	set x=$get(^a)
	write "# Now rerun [write $view(""NOISOLATION"",""^a"")]. Still expect output of 1.",!
	write "# Before GT.M V7.0-001 fixes to GTM-9392, the output used to be 0.",!
	write $view("noisolation","^a"),!
	quit

