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
;
parent
	do ^job("child^gtm8680",1,"""""")
	quit

child
	for i=1:1:10000 do
	. set t1=$h
	. lock +^X(i)
	. set t2=$h
	. write $$^difftime(t1,t2)," "
	zsystem "$ydb_dist/lke SHOW -all"
	quit
