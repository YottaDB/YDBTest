;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb315

	quit

nosetZcomp
	ZCOMPILE "$gtm_tst/r124/inref/blktoodeep.m"

        quit

setZcompNoWarning
	SET $ZCOMPILE=$ZCOMPILE_" -nowarning"
	ZCOMPILE "$gtm_tst/r124/inref/blktoodeep.m"

	quit


setZcompWarning
	SET $ZCOMPILE=$ZCOMPILE_" -warning"
	ZCOMPILE "$gtm_tst/r124/inref/blktoodeep.m"

	quit
