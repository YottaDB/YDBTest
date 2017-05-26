;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Called from inst_freeze_enospc. Launches 4 processes that do TP and NON-TP updates. The number of updates are enough to fit in
; the designated file system. If you decide to change the number of updates or record lengths, you need to adjust file system
; accordingly
fill
	write $j
	set jmaxwait=18000
	do ^job("start^fill",4,"""""")
	halt
start
	for i=(index-1)*50+1:1:index*50 do
	.   if (index#2=0) TSTART ()
	.   set ^x(i)=$j(" ",1000)
	.   set ^a(i)=$j(" ",1000)
	.   set ^b(i)=$j(" ",1000)
	.   set ^c(i)=$j(" ",1000)
	.   set ^d(i)=$j(" ",1000)
	.   set ^e(i)=$j(" ",1000)
	.   set ^f(i)=$j(" ",1000)
	.   if (index#2=0) TCOMMIT
	 write $j," DONE",!
