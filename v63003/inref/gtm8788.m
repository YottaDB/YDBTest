;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test that BLKTOODEEP error lines are excluded from object file (GTM-8788 fixed in GT.M V6.3-003)
;
indent
	do case1
	do case2
	quit

case1	;
	for i=1:1:2  do
	. write "case1 : ",i," : This line should be displayed",!
	if $incr(i)
	write "case1 : ",i," : This line should be displayed",!
	quit

case2	;
	for i=1:1:2  ; do
	. write "case2 : ",i," : This line should NOT be displayed",!
	if $incr(i)
	write "case2 : ",i," : This line should be displayed",!
	if $incr(i)
	. Write "case2 : ",i," : This line should NOT be displayed",!
	if $incr(i)
	write "case2 : ",i," : This line should be displayed",!
	quit
