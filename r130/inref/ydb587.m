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

; Writing the value of environment variable
testwrt
	write "Value of $TEST in YDB is ",$TEST,!
	quit

altreg
	set $zgbldir="alt.gld"
	write $ztrigger("item","+^CIF -commands=SET -xecute=""DO alttrig^ydb587"" -name=xyz")
	quit

setval
	set ^CIF=1
	quit

alttrig
	write "Executing Trigger",!
	write "Value of $TEST is ",$TEST,!
	quit
