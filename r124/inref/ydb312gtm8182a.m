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

gtm8182a
	DO getPaths

	WRITE "    Update the INST1 DB",!
	SET ^today="7/18/2018"

	WRITE "    Read from INST3 DB",!
	WRITE "        Django: ",^|INST3gbldir|Django,!

	;call jnlprocnum.csh to return the number or processes attached
	;to our JNL pools
	ZSYSTEM "$gtm_tst/r124/u_inref/jnlprocnum.csh"

	quit

updateINST3
	DO getPaths
	SET $ZGBLDIR=INST3gbldir
	SET ^Django="Unchained"

	quit

getPaths
	SET INST1path=$ZTRNLNM("path_INST1")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET INST3path=$ZTRNLNM("path_INST3")
	SET INST3gbldir=INST3path_"/mumps.gld"

	quit
