;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

ydb994gvsuboflow	;
	set $etrap="write $extract($zstatus,1,103),! set $ecode="""""
	for max=1020:1:1050 do gvsuboflow(max)
	quit

gvsuboflow(max)	;
	set x=$tr($justify(1,max)," ",1) write ^names(x)
	quit

