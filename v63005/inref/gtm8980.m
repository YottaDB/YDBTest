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
gtm8980
	quit

test1
	WRITE "Testing that $VIEW(""STATSHARE"") returns the correct values",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW ""STATSHARE"" "
	VIEW "STATSHARE"
	WRITE !

	WRITE "$VIEW(""STATSHARE""): ",!
	WRITE $VIEW("STATSHARE"),!
	WRITE !

	WRITE "VIEW ""NOSTATSHARE"" "
	VIEW "NOSTATSHARE"
	WRITE !

	WRITE "$VIEW(""STATSHARE""): ",!
	WRITE $VIEW("STATSHARE"),!
	WRITE !

	WRITE "VIEW ""STATSHARE"":""AREG"" "
	VIEW "STATSHARE":"AREG"
	WRITE !

	WRITE "$VIEW(""STATSHARE""): ",!
	WRITE $VIEW("STATSHARE"),!
	WRITE !


	quit

test2
	WRITE "Test $VIEW(""STATSHARE"",""<region>"") for selectively disabled region",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW ""NOSTATSHARE"" "
	VIEW "NOSTATSHARE"
	WRITE !

	WRITE "VIEW ""NOSTATSHARE"":""BREG"" "
	VIEW "NOSTATSHARE":"BREG"
	WRITE !

	WRITE "$VIEW(""STATSHARE"",""BREG""): ",!
	WRITE $VIEW("STATSHARE"),!
	WRITE !

	quit

test3a
	WRITE "Test $VIEW(""JNLWAIT"") error message for parameter name",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "$VIEW(""JNLWAIT""): ",!
	WRITE $VIEW("JNLWAIT"),!
	WRITE !

	quit

test3b
	WRITE "Test VIEW ""GVFILE"":""DEFAULT"" error message for parameter name",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW ""GVFILE"":""DEFAULT"" "
	VIEW "GVFILE":"DEFAULT"
	WRITE !
	quit

test3c
	WRITE "Test VIEW ""BREAKMSG"":32 error message for second parameter name",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW ""BREAKMSG"":31 ",!
	VIEW "BREAKMSG":31
	WRITE "VIEW ""BREAKMSG"":32 ",!
	VIEW "BREAKMSG":32

	quit
