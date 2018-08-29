;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

tprestart	;
	set ^stop=0,^njobs=5		 	 ; signal child processes to proceed
	do ^job("child^tprestart",^njobs,"""""") ; start 5 jobs
        quit

child  ;
	for i=1:1  quit:^stop=^njobs  do
	.	tstart ():serial
	.	set x=$incr(^c)
	.	if $r(2) set ^a($j,x)=$j(1,220)
	.	if $r(2) set ^b($j,x)=$j(2,220)
	.	if $r(2) set ^c($j,x)=$j(3,220)
	.	tcommit
	.	if i=100 set x=$incr(^stop)	; once this child has done 100 TP transactions, signal it is okay to stop
	.					; as we expect at least some of those TP transactions to have seen a TPRESTART
	quit
