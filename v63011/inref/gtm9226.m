;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtm9226
	view "NOBADCHAR"
	set y=$zchar(128)_$zchar(194)
	; The $translate is structured so the 2-byte ascii input string "ba" is replaced with a 2-byte string which is the 2-byte
	; UTF-8 representation of $CHAR(128). This used to be treated as a 2-character length string in V6.3-010 but was fixed to
	; be treated as a 1-character length string in V6.3-011 by GTM-9226.
	set x=$translate("ba","ab",y)
	write $length(x),!
