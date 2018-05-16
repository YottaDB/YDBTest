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
testA

	WRITE "    $VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	WRITE !
	WRITE "    VIEW ""STATSHARE"" ",!
	VIEW "STATSHARE"
	WRITE !

	WRITE "    $VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	quit

testB

	WRITE "    $VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "    $VIEW(""STATSHARE"",""AREG""): "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	WRITE !
	WRITE "    VIEW ""STATSHARE"":""DEFAULT"" ",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE !

	WRITE "    $VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "    $VIEW(""STATSHARE"",""AREG""): "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	quit

testC

	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	WRITE !
	WRITE "    VIEW ""STATSHARE"":""DEFAULT"" ",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE !

	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	WRITE !
	WRITE "    VIEW ""STATSHARE"" ",!
	VIEW "STATSHARE"
	WRITE !

	WRITE "    $VIEW(""STATSHARE""): "
	WRITE $VIEW("STATSHARE"),!

	quit
