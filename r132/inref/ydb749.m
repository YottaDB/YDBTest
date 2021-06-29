;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb749	;
	; Do a HUGE TP transaction in terms of journal data (not in terms of database block updates).
	; Hence we update the same node inside the for loop instead of different nodes.
	;
	set numupdates=+$piece($zcmdline," ",1)
	set randomrange=+$piece($zcmdline," ",2)
	set actualnumupdates=numupdates+$select(randomrange=0:0,1:$random(randomrange))
	for iters=1:1:3 do	 ; need to do 3 iterations to reproduce JNLCNTRL error with older build before YDB#749 fixes
        . tstart ():serial
        . for i=1:1:actualnumupdates set ^x=$j(i,1000)
        . tcommit
	quit
