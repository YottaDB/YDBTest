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
	SET INST1repl=INST1path_"/mumps.repl"

	SET INST3path=$ZTRNLNM("path_INST3","","","","","VALUE")
	SET INST3gbldir=INST3path_"/mumps.gld"
	SET INST3repl=INST3path_"/mumps.repl"

	WRITE "INST1gbldir: "
	WRITE INST1gbldir,!

	WRITE "INST3gbldir: "
	WRITE INST3gbldir,!

	WRITE "ZGBLDIR: ",$ZGBLDIR,!
	; Update the DB of INST1
	SET ^jake="youngest"

	; Switch to global directory for INST3
	SET $ZGBLDIR=INST3gbldir
	WRITE "ZGBLDIR: ",$ZGBLDIR,!
	;DO setenv^%POSIX("ydb_gbldir",INST3gbldir,1) ; setenv gbl dir to INST3's
	;ZSYSTEM "$GDE CHANGE -INSTANCE -FILE_NAME="""_INST3repl_""""
	ZSYSTEM "setenv ydb_gbldir """_INST3gbldir_""" ; "_"$GDE CHANGE -INSTANCE -FILE_NAME="""_INST1repl_""""

	; Update the DB of INST3
	SET ^zack="oldest"

	; Switch back to global directory for INST1
	SET $ZGBLDIR=INST1gbldir
	WRITE "ZGBLDIR: ",$ZGBLDIR,!
	;DO setenv^%POSIX("ydb_gbldir",INST1gbldir,1) ; setenv gbl dir back to INST1's
	;ZSYSTEM "$GDE CHANGE -INSTANCE -FILE_NAME="""_INST1repl_""""
	ZSYSTEM "setenv ydb_gbldir """_INST1gbldir_""" ; "_"$GDE CHANGE -INSTANCE -FILE_NAME="""_INST1repl_""""

	quit
