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
gtm8092	;
	;
	; this M program assumes the jnlpool size is < 2Mb and uses this to force source server to read from FILES (not POOL)
	;
	quit
test1	;
	tstart ():serial
	for i=1:1:4 set ^x($incr(j))=$justify(j,2**20)
	tcommit
	; cause jnlpool overflow to force source server to read previous seqno from jnl file
	for i=1:1:2 set ^x($incr(j))=$justify(j,2**20)
	; sending the above seqno in file mode will cause the source server to set max_tr_size to ~ 4Mb in V61000
	quit

test2	;
	tstart ():serial
	for i=1:1:3 set ^x($incr(j))=$justify(j,2**20-148)
	; 111 is the value which showed an assert failure in V61000 but we want to test more cases so randomly choose
	; from the range of 32 values i.e. 7, 15, 23, ... 111, 119, ... 247, 255.
	set ^x($incr(j))=$justify(j,(1+$random(32))*8-1)
	tcommit
	; cause jnlpool overflow to force source server to read previous seqno from jnl file
	for i=1:1:2 set ^x($incr(j))=$justify(j,2**20)
	quit

