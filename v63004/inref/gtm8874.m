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

	WRITE !,"VIEW ""NOSTATSHARE"" ",!
	VIEW "NOSTATSHARE"
	do checkRegion()
	WRITE !

	WRITE "VIEW ""STATSHARE"":""AREG"""
	VIEW "STATSHARE":"AREG"
	WRITE !
	do checkRegion()
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

	WRITE "VIEW ""STATSHARE"""
	VIEW "STATSHARE"
	WRITE !
	do checkRegion()
	WRITE !

	WRITE "VIEW ""NOSTATSHARE"""
	VIEW "NOSTATSHARE"
	WRITE !
	do checkRegion()
	WRITE !

	quit


testB
	WRITE "----------",!
	WRITE "testB",!
	WRITE "----------",!!

	WRITE "VIEW ""STATSHARE"""
	VIEW "STATSHARE"
	WRITE !
	do checkRegion()
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

	WRITE "VIEW ""NOSTATSHARE"":""DEFAULT"" ",!
	VIEW "NOSTATSHARE":"DEFAULT"
	WRITE !
	do checkRegion()
	WRITE !

	WRITE "SET $ZGBLDIR=""otherB.gld"" ",!
	SET $ZGBLDIR="otherB.gld"

	WRITE !
	do checkRegion()

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

	WRITE !,"Check Sharing Status:",!

	set reg=""
	for  set reg=$view("GVNEXT",reg) quit:reg=""  DO
	. WRITE "STATSHARE "_reg_": "
	. WRITE $VIEW("STATSHARE",reg),!

	WRITE "STATSHARE: "
	WRITE $VIEW("STATSHARE"),!

	WRITE "^%YGS : ",!
	IF $data(^%YGS)  DO
	. ZWR ^%YGS

	ELSE  DO
	. WRITE "NO REGION"

	quit

