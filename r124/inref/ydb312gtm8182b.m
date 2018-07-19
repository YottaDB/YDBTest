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

ydb231gtm8182b
	DO getPaths

	set $ZGBLDIR=INST1gbldir
	set x=$get(^a)
	set $ZGBLDIR=INST3gbldir

	set incrtrapNODISP=1
	set $ZTRAP="goto incrtrap^incrtrap"
	write "$zrealstor BEFORE $ZPEEK loop is ",$zrealstor,!
	for i=1:1:1000 do zpeek
	write "$zrealstor AFTER  $ZPEEK loop is ",$zrealstor,!

	quit

zpeek ;
	; Doing a \$zpeek instead of PEEKBYNAME in order to avoid ^incrtrap issues
	; write \$\$^%PEEKBYNAME("jnlpool_ctl_struct.ftok_counter_halted")
	set ret=$zpeek("JPCREPL",3708,4,"I")

	quit


getPaths
	SET INST1path=$ZTRNLNM("path_INST1","","","","","VALUE")
	SET INST1gbldir=INST1path_"/mumps.gld"

	SET INST3path=$ZTRNLNM("path_INST3","","","","","VALUE")
	SET INST3gbldir=INST3path_"/mumps.gld"

	quit

