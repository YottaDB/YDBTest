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
	SET INST1path=$ZTRNLNM("path_INST1","","","","","VALUE")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET INST3path=$ZTRNLNM("path_INST3","","","","","VALUE")
	SET INST3gbldir=INST3path_"/mumps.gld"

	WRITE "    Update the INST1 DB",!
	SET ^jake="youngest"

	WRITE "    Switch to INST3 gbldir",!
	SET $ZGBLDIR=INST3gbldir

	WRITE "    Update the INST3 DB",!
	SET ^zack="oldest"

	WRITE "    Switch back to INST1 gbldir",!
	SET $ZGBLDIR=INST1gbldir

	WRITE !

	quit
