;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2022 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ydb312gtm8182g

	DO getPaths

	WRITE !

	WRITE "     Before updates: ",!
	WRITE "     ----------------: ",!
	DO numProc
	DO ftok
	WRITE !

	WRITE "     Updating through GBL1.gld",!
	SET $ZGBLDIR=GBL1path
	SET ^Protagonist="Hamilton"
	WRITE "     Updating through GBL2.gld",!
	SET $ZGBLDIR=GBL2path
	SET ^Antagonist="Burr"
	WRITE !

	WRITE "     After updates: ",!
	WRITE "     ----------------: ",!
	DO numProc
	DO ftok
	WRITE !

	quit

getPaths

	SET INST1path=$ZTRNLNM("path_INST1")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET GBL1path=INST1path_"/GBL1.gld"
	SET GBL2path=INST1path_"/GBL2.gld"

	quit

numProc
	WRITE "     Number of processes attached to journal pool of mumps.repl: "

	ZSYSTEM "$ydb_dist/mupip ftok -jnlpool mumps.repl |& $grep jnlpool | $tst_awk '{print $6}' >& shm1.out ; $gtm_tst/com/ipcs -a | $grep -w `cat ./shm1.out` | $tst_awk '{print $NF}'"

	quit

ftok
	WRITE "     "

	ZSYSTEM "set repl_ftok_semid = `$gtm_dist/ftok -id=44 $gtm_repl_instance | awk '{print $5}'` ; $gtm_dist/semstat2 `$gtm_tst/com/ipcs -s | $grep -w $repl_ftok_semid | awk '{print $2}'` | $grep 'sem  1' | sed 's/sem  1/JNLPOOL ftok : '$gtm_repl_instance' /g' "

