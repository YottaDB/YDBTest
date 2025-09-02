;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

parent ;
	kill ^x,^y,^a,^b,^njobs,^stop
	set ^a(1)=1,^b(2)=1,^njobs=4,^stop=0
	for i=1:1:^njobs do
	. set jobstr="job child^ydb665b:(output=""child_ydb665b.mjo"_i_""":error=""child_ydb665b.mje"_i_""")"
	. xecute jobstr
	. set ^child(i)=$zjob
	hang $random(1000)*0.001
	for i=1:1:^njobs if $zsigproc(^child(i),10)
	hang $random(1000)*0.001
	set ^stop=1
	for i=1:1:^njobs set pid=^child(i) for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.001
	zsystem "cat child_ydb665b.mjo*"
	quit

child	;
	set $etrap="zwrite $zstatus set ^stop=1 halt"
	set $zinterrupt="if $incr(x)"
	for i=1:1:1000000 quit:^stop=1  do
	. set x=^a(1)
	. lock (^x(^a(1),^b(2)))
	quit

