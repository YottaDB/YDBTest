;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
jnlnojnl	;
	for i=1:1:1000 do
	. set ^aglobal(i)=$justify(i,100)
	. set ^bglobal(i)=$justify(i,100)
	. set ^cglobal(i)=$justify(i,100)
	. set ^dglobal(i)=$justify(i,100)
	. set ^eglobal(i)=$justify(i,100)
	. set ^fglobal(i)=$justify(i,100)
	. set ^gglobal(i)=$justify(i,100)
	. set ^hglobal(i)=$justify(i,100)
