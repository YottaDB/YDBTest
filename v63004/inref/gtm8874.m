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
	WRITE "----------",!
	WRITE "testA",!
	WRITE "----------",!!

	do checkRegion()

	WRITE !,"VIEW ""STATSHARE"" ",!
	VIEW "STATSHARE"
	do checkRegion()
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	WRITE !,"VIEW ""NOSTATSHARE"" ",!
	VIEW "NOSTATSHARE"
	do checkRegion()
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
	do checkRegion()
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
	WRITE !
	do checkRegion()
	WRITE !
	WRITE "VIEW ""NOSTATSHARE"":""AREG""",!
	VIEW "NOSTATSHARE":"AREG"
	WRITE !
	do checkRegion()
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
	do checkRegion()
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
	do checkRegion()
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	quit



testB1
	WRITE "----------",!
	WRITE "testB1",!
	WRITE "----------",!!

	WRITE "VIEW ""STATSHARE"""
	VIEW "STATSHARE"
	WRITE !
	do checkRegion()
	WRITE !

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	quit

testB2
	WRITE "----------",!
	WRITE "testB2",!
	WRITE "----------",!!

	WRITE "STATSHARE DEFAULT: "
	WRITE $VIEW("STATSHARE","DEFAULT"),!
	WRITE "STATSHARE AREG:    "
	WRITE $VIEW("STATSHARE","AREG"),!
	WRITE "STATSHARE BREG:    "
	WRITE $VIEW("STATSHARE","BREG"),!
	WRITE !

	quit


testC
	WRITE "----------",!
	WRITE "testC",!
	WRITE "----------",!!

	WRITE "SET $ZGBLDIR=""otherA.gld"" ",!
	SET $ZGBLDIR="otherA.gld"

	WRITE "VIEW ""STATSHARE"":""DEFAULT"" ",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE !
	do checkRegion()
	WRITE !
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!!

	WRITE "VIEW ""NOSTATSHARE"":""DEFAULT"" ",!
	VIEW "NOSTATSHARE":"DEFAULT"
	WRITE !
	do checkRegion()
	WRITE !
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!!

	WRITE "SET $ZGBLDIR=""otherB.gld"" ",!
	SET $ZGBLDIR="otherB.gld"

	WRITE "VIEW ""STATSHARE"":""DEFAULT"" ",!
	VIEW "STATSHARE":"DEFAULT"
	WRITE !
	do checkRegion()
	WRITE !
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!!

	WRITE "VIEW ""NOSTATSHARE"":""DEFAULT"" ",!
	VIEW "NOSTATSHARE":"DEFAULT"
	WRITE !
	do checkRegion()
	WRITE !
	WRITE "$VIEW(""STATSHARE"",""DEFAULT""): "
	WRITE $VIEW("STATSHARE","DEFAULT"),!!

	quit

checkRegion()

	WRITE "Check for open region files:",!

	; Filters the file names from the ls output
	ZSYSTEM "ls -l /proc/"_$job_"/fd | $grep '.dat$' | awk -F '/' '{print $(NF)}' | sort"


	; .gst files start with an RNG number, so the file names themselves require additional filtering

	set line1="ls -l /proc/"_$job_"/fd | $grep '.gst$' | "
	set line2="awk -F '/' '{print $(NF)}'  | "
	set line3="awk -F '.' 'BEGIN { ORS="""" }; {print ""xxx""; for (i = 2; i <= NF ; i++) { print ""."" ; print $i } print ""\n""}' | "
	set line4=" sort"

	ZSYSTEM line1_line2_line3_line4

