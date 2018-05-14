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
gtm8874()

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	WRITE "VIEW ""STATSHARE"":""AREG"""
	VIEW "STATSHARE":"AREG"
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	WRITE "VIEW ""STATSHARE"":""DEFAULT""",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE "VIEW ""NOTSTATSHARE"":""AREG""",!
	VIEW "NOSTATSHARE":"AREG"
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	WRITE "VIEW ""STATSHARE"""
	VIEW "STATSHARE"
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	WRITE "VIEW ""NOSTATSHARE"""
	VIEW "NOSTATSHARE"
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	quit
