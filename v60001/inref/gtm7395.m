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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7395 ;
	; OPEN with READONLY should return EISDIR
	;

	; handle EISDIR trap
	new $ETRAP
	set $ETRAP="do errorHandler"
	write "Producing two YDB-EISDIRs",!
	do readonlyTest
	do noreadonlyTest
	write "Done",!
	quit


readonlyTest
	open "gtm7395_dummy_dir":(READONLY)
	quit


noreadonlyTest
	open "gtm7395_dummy_dir":(NOREADONLY)
	quit

errorHandler
	set errMsg=$PIECE($ZSTATUS,",",3)
	if errMsg="%YDB-E-GTMEISDIR" write $ZSTATUS,! set $ECODE=""
	else  write $ZSTATUS,!
	quit
