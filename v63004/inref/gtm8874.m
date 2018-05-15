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
	WRITE "Check for open region files:",!
	ZSYSTEM "ls -l /proc/"_$job_"/fd | $grep '.dat$' | awk -F '/' '{print $(NF)}' "
	WRITE !,"VIEW ""STATSHARE"" ",!
	VIEW "STATSHARE"
	WRITE "Check for open region files:",!
	ZSYSTEM "ls -l /proc/"_$job_"/fd | $grep '.dat$' | awk -F '/' '{print $(NF)}' "
	WRITE !

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



testB
	;WRITE "VIEW ""NOSTATSHARE"""
	;VIEW "NOSTATSHARE"
	;WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	quit


testC
	WRITE "SET $ZGBLDIR=""otherA.gld"" ",!
	SET $ZGBLDIR="otherA.gld"
	WRITE "VIEW ""STATSHARE"":""DEFAULT"" ",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!!

	WRITE "SET $ZGBLDIR=""otherB.gld"" ",!
	SET $ZGBLDIR="otherB.gld"
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!

	quit
