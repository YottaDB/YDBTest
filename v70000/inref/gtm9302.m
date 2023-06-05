;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Helper functions for v70000/gtm9302
;

;
; Routine to simply add some records to DB.
;
dbInit
	for i=1:1:10000 set ^z=$justify(i,105)
	set ^done=1
	quit

;
; Wait for ^done to show up
;
waitDone
	for  quit:1=$get(^done,0)  hang .25
	quit


;
; Write out acknowledged sequence number. Note value is reduced by one as that is what is done inside
; gtmsource_showbacklog.c when printing the same value out as part of MUPIP REPLIC -SOURCE -SHOWBACKLOG.
;
writeSeqno
	new seqno
	set seqno=($$FUNC^%HD($$^%PEEKBYNAME("gtmsource_local_struct.heartbeat_jnl_seqno",0)))
	set seqno=$select(seqno=0:seqno,seqno>0:seqno-1) ; Only decrement if > 0 - error if seqno is negative
	write seqno,!
	quit

