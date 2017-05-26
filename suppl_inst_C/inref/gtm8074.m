;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8074	;
	quit

updinstA1 ;
	; inflate jnl_seqno to a high value with db containing no nodes at the end
	; will help inflate strm_seqno on supplementary instance later (relative to jnl_seqno of instance)
	; this was failing some asserts and so this is a test to exercise that code path.
	for i=1:1:10000 set ^a=i
	kill ^a
	quit

updinstP1 ;
	for i=1:1:10 set ^pinst(i)=i
	quit

updinstA2 ;
	for i=1:1:10 set x=$incr(^ainst)
	quit

updinstP2 ;
	for i=1:1:10 set x=$incr(^pinst)
	quit

