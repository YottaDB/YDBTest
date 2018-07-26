;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
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

test1a
	WRITE "Testing that VIEW can take an empty string without seg fault",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW """" ",!
	VIEW ""

	quit

test1b
	WRITE "Testing that $VIEW can take an empty string without seg fault",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "$VIEW ("""") ",!
	WRITE $VIEW("")

	quit

test2
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

test3
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

test4a
	WRITE "Test $VIEW(""GARBAGE PARAMETER"") error message for parameter name",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "$VIEW(""GARBAGE PARAMETER""): ",!
	WRITE $VIEW("GARBAGE PARAMETER"),!
	WRITE !

	quit

test4b
	WRITE "Test VIEW ""GARBAGE PARAMETER"" error message for parameter name",!
	WRITE "--------------------------------------------------------------------------",!!

	WRITE "VIEW ""GARBAGE PARAMETER"" "
	VIEW "GARBAGE PARAMETER"
	WRITE !

	quit
