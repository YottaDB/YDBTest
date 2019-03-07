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
;
gtm8914

	WRITE "$VIEW(""GVSTATS"",""DEFAULT"")",!
	WRITE $VIEW("GVSTATS","DEFAULT"),!

	WRITE "ZSHOW ""G"" ",!
	ZSHOW "G"

	WRITE "ZSHOW ""T"" ",!
	ZSHOW "T"

	WRITE !

	quit
