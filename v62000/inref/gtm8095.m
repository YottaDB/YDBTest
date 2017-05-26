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
gtm8095	;
	;
	; this M program assumes the jnlpool size is < 2Mb and uses this to force source server to read from FILES (not POOL)
	;
	tstart ():serial
	set ^a($incr(j))=$justify(j,2**20-58)
	set ^b($incr(j))=$justify(j,2**20-58)
	; any value from 201 thru 256 produces an assert in V61000 so we try a random value from this range.
	set ^c($incr(j))=$justify(j,2**20-201-$random(56))
	tcommit
	; cause jnlpool overflow to force source server to read previous seqno from jnl file
	for i=1:1:2 set ^x($incr(j))=$justify(j,2**20)
	quit
