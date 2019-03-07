;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

setVars
	SET ^string1="Its dangerous to go alone take this"
	SET ^string2="Wibboly Wobboly Timey Whimey"
	SET ^string3="Lightning Bolt! Lightning Bolt! Lightning Bolt!"
	SET ^string4="'To infinity and beyond' - Buzz Aldrin"
	quit

showVars
	WRITE "^string1: "_^string1,!
	WRITE "^string2: "_^string2,!
	WRITE "^string3: "_^string3,!
	WRITE "^string4: "_^string4,!
	quit



