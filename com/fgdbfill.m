;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
fgdbfill;
	; For now following routines are called.
	; All of these run in foreground.
	; Note that rinttp is multi-process.
	; Others are single process.
	do ^rinttp(1)
	do ^rinttp(2)
	do ^rinttp(3)
	d ^replrec
	d in1^dbfill("set")
	d in1^dbfill("ver")
	q
