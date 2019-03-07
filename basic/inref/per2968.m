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
;	PER 2968:  A called M routine gets changed while still in GT.M;  the
;		   changes include deleting a label that was referenced in
;		   the calling routine.  After ZLINKing the changed routine
;		   and re-running the calling routine, the reference to the
;		   no-longer-existing label produced a SYSTEM-F-OPCDEC error,
;		   instead of the correct YDB-E-LABELUNKNOWN error.
;
per2968	d ^per2968a
	zlink "per2968b.edit"
	d ^per2968a
	q
