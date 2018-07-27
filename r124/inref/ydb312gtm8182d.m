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

gtm8182
	DO getPaths
	set tab="    "
	SET $ZGBLDIR=INST1gbldir
	WRITE tab_"Attempting to read from DB",!
	SET x=$get(^a)
	WRITE !

	
	WRITE tab_"Start INST1 INST2 replication",!
	ZSYSTEM "$MSR STARTSRC INST1 INST2"
	WRITE !

	WRITE tab_"Attempting to write to DB",!
	SET ^a=1

	quit

getPaths

	SET INST1path=$ZTRNLNM("path_INST1")
	SET INST1gbldir=INST1path_"/mumps.gld"

	quit
