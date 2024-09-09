;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; This is a copy of the test M program at https://gitlab.com/YottaDB/DB/YDB/-/issues/1097#note_2097060874

ydb1097e	;
	set a=0
	if a do
	. write 1
	. ; dummy comment line INSIDE dotted DO frame should still cause FALLINTOFLST error
	. ; (to test comment at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2089#note_2098016429)
sub2(arg)
	write "Should not reach here",!
	quit

