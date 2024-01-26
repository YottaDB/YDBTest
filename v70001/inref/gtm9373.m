;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

gtm9373	;
	quit

startbgupdates;
	set jmaxwait=0,^stop=0
	do ^job("child^gtm9373",1,"""""")
	quit

child	;
	for i=1:1  quit:^stop=1  set ^gtm9373(i)=i
	quit

endbgupdates;
	set ^stop=1
	do wait^job
	quit

waitAcknowledgedIncrease	;
	; wait until acknowledged seqno (i.e. heartbeat_seqno) is more than its current value (i.e. $zcmdline)
	set acknowledged=+$zcmdline+1
	for  quit:acknowledged<$$FUNC^%HD($$^%PEEKBYNAME("gtmsource_local_struct.heartbeat_jnl_seqno",0))  hang 0.001
	quit

