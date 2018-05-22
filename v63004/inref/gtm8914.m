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
gtm8914


	DO showStats()

	WRITE !
	WRITE "$MUPIP set -STAT -reg BREG",!
	ZSYSTEM "$MUPIP set -STAT -reg ""BREG"""
	ZSYSTEM "$gtm_dist/mupip SET -STAT  -reg ""BREG"""
	ZSYSTEM "$ydb_dist/mupip SET -STAT  -reg ""BREG"""
	WRITE !

	DO showStats()
	;WRITE "VIEW ""STATSHARE"" ",!
	;VIEW "STATSHARE"

	;WRITE !
	;WRITE "$VIEW(""STATSHARE""): "
	;WRITE $VIEW("STATSHARE"),!

 	;DO showStats()
	;
	;
	;WRITE "VIEW ""NOSTATSHARE"" ",!
	;VIEW "NOSTATSHARE"

	;WRITE "$VIEW(""STATSHARE""): "
	;WRITE $VIEW("STATSHARE"),!
	;WRITE !

 	;DO showStats()

	quit

showStats()

	WRITE "$VIEW(""GVSTATS"",""DEFAULT"")",!
	WRITE $VIEW("GVSTATS","DEFAULT")

	WRITE "$VIEW(""GVSTATS"",""BREG"")",!
	WRITE $VIEW("GVSTATS","BREG")

	WRITE "ZSHOW ""G""",!
	ZSHOW "G"

	WRITE "ZSHOW ""T""",!
	ZSHOW "T"

	WRITE !

	quit
