;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8499	;
	; GTM-8499 KILL ^GBLNODE terminates abnormally with SIG-11 in rare situations
	;
	; The testcase creates a small global ^x and a huge global ^a in the same region.
	; And then accesses the small global inside a TP transaction which would have initialized the
	; gv_target->hist.h[0].first_tp_srch_status to point to structures malloced inside the TP transaction.
	; Once the TP transaction is done, we do another TP transaction that reads the big global (merge into
	; a local variable). We ensure this global has 64 nodes (INIT_CUR_TP_HIST_SIZE) because that is the amount
	; needed to cause the TP structure to expand which will cause the original structure to be freed and
	; initialized to garbage because of the gtmdbglvl setting. And then when we come back to accessing the
	; small global in a non-TP transaction, pre-V63000 we would dereference the first_tp_srch_status field
	; which now points to garbage because of the free.
	;
	set ^x=1
	for i=1:1:64 set ^a(i)=$j(i,900)
	tstart ():serial set ^x=2  tcommit
	tstart ():serial merge x=^a tcommit
	kill ^x
	quit
