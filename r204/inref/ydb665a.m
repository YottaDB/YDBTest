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

parent	;
	set ^stop=0
	kill ^x,^y
	job child^ydb665a:(output="child_ydb665a.mjo1":error="child_ydb665a.mje1")
	for  quit:$data(^x(1))  hang 0.001
	for i=1:1:10 if $zsigproc($zjob,10)  hang 0.001  quit:^stop=1
	set ^stop=1
	for  quit:'$zgetjpi($zjob,"ISPROCALIVE")  hang 0.001
	zsystem "cat child_ydb665a.mjo1"
	quit

child	;
	set $etrap="zwrite $zstatus set ^stop=1 halt"
	set $zinterrupt="if $incr(x)"
	kill ^y
	for i=1:1:100 set ^y(1,i)=i
	for i=1:1 quit:^stop=1  do
	. set x=$get(^y(1))
	. merge ^x(i)=^y(1)
	quit
