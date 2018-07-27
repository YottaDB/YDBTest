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

ydb312gtm8182e

	DO getPaths

	WRITE "    Change to INST1 global directory and set ^a",!
	SET $ZGBLDIR=INST1gbldir
	SET ^a=1
	WRITE "    Change to INST3 global directory and set ^a",!
	WRITE "    (Expecting REPLINSTUNDEF error)",!
	SET $ZGBLDIR=INST3gbldir
	SET ^a=1

	quit

getPaths

	SET INST1path=$ZTRNLNM("path_INST1")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET INST3path=$ZTRNLNM("path_INST3")
	SET INST3gbldir=INST3path_"/mumps.gld"

	quit

