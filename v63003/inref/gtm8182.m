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

	WRITE "    Update the INST1 DB",!
	SET ^jake="youngest"
	WRITE "    Update the INST3 DB with an extended reference",!
	SET ^|INST3gbldir|zack="oldest"

	WRITE "    Switch to INST3 gbldir",!
	SET $ZGBLDIR=INST3gbldir

	WRITE "    Update the INST3 DB",!
	SET ^jim="father"
	WRITE "    Update the INST1 DB with an extended reference",!
	SET ^|INST1gbldir|wendy="mother"

	WRITE "    Switch back to INST1 gbldir",!
	SET $ZGBLDIR=INST1gbldir

	WRITE !

	quit

TP1
	DO getPaths

	TSTART
	WRITE "    Update the INST1 DB",!
	SET ^mike="uncle"
	TCOMMIT

	TSTART
	WRITE "    Update the INST1 DB",!
	SET ^edd="uncle"
	WRITE "    Update the INST3 DB with an extended reference",!
	SET ^|INST3gbldir|grace="grandmother"
	TCOMMIT

	quit

TP2
	DO getPaths

	TSTART
	WRITE "    Update the INST1 DB",!
	SET ^edd="uncle"
	WRITE "    Update the INST3 DB with an extended reference",!
	SET ^|INST3gbldir|harley="cousing"
	TCOMMIT

	quit

testPool
	DO getPaths

	; A variable in the DB  must be accessed to open the JNL POOL for the process
	SET jake=^jake
	SET ^jake=jake
	WRITE "    JNL POOL INST1: ",!
	WRITE "    ",$VIEW("JNLPOOL"),!
	WRITE !

	WRITE "    Switch to INST3 gbldir",!,!
	SET $ZGBLDIR=INST3gbldir

	; A variable in the DB  must be accessed to open the JNL POOL for the process
	SET jim=^jim
	SET ^jim=jim
	WRITE "    JNL POOL INST3: ",!
	WRITE "    ",$VIEW("JNLPOOL"),!
	WRITE !

	WRITE "    Update the INST1 DB with an extended reference: ",!
	SET jake=^|INST3gbldir|jake
	SET ^|INST3gbldir|jake=jake
	WRITE "    JNL POOL INST3: ",!
	WRITE "    ",$VIEW("JNLPOOL"),!

	quit

getPaths

	SET INST1path=$ZTRNLNM("path_INST1","","","","","VALUE")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET INST3path=$ZTRNLNM("path_INST3","","","","","VALUE")
	SET INST3gbldir=INST3path_"/mumps.gld"

	quit
