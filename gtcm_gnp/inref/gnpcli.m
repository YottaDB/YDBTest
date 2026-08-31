;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; The GT.CM client half of the fake server cases. Issues one $QUERY against a region that
; inref/gnpsrv.m is answering, and reports what the client made of the reply it got back.
;
; $ZCMDLINE : <case>
;
gnpcli	;
	new q
	set case=$piece($zcmdline," ",1)
	set $etrap="do trap^gnpcli"
	set q=$query(^etpr)
	if case="srvidleframe" do
	. ; The fake server has queued a length prefix larger than this client's message buffer on the
	. ; link while this process is between operations, where it leaves no read outstanding. The
	. ; cmi_read() the $QUERY below issues therefore finds those bytes already in the socket buffer
	. ; and its recv() returns them on the spot, which is the synchronous path in cmj_read_start().
	. ; Wait for the file the fake server writes after sending them: if the $QUERY gets there first
	. ; the bytes arrive with a read outstanding and go through cmj_read_interrupt() instead, which
	. ; is the path srvbigframe already covers.
	. if $$FUNC^waitforfilecreate("queued",30,1) write case_" : fake server never queued the announcement - WRONG",! halt
	. set q=$query(^etpr)
	use $principal write case_" : accepted the reply, $QUERY returned "_$zwrite(q),!
	halt
	;
trap	; the client rejecting a reply it cannot parse is a normal outcome here, not a test failure
	new v
	set v=$zstatus
	set $ecode=""
	use $principal
	; A reply the client cannot parse gives BADSRVRNETMSG. "srvbigframe" and "srvidleframe" are the
	; two cases where there is no message to reject: each announces a reply and sends none of it, so
	; the client fails the operation instead. What matters there is that it fails rather than
	; hanging, which is what it did when the read path returned leaving the CLB in CM_CLB_READ with
	; no read outstanding and no event posted. The two differ only in which read path sees the
	; announcement: cmj_read_interrupt() for srvbigframe, cmj_read_start() for srvidleframe.
	if $zfind(v,"BADSRVRNETMSG") write case_" : rejected with BADSRVRNETMSG",!
	else  if ((case="srvbigframe")!(case="srvidleframe")),$zfind(v,"GVQUERYFAIL") write case_" : the operation failed rather than hanging",!
	else  write case_" : UNEXPECTED, "_$zpiece(v,",",3)_" - WRONG",!
	halt
