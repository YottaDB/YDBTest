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

ydb721	;
	; YDB#721 : Test that LKE SHOW does not insert a line feed after a lock reference longer than 24 chars
	;
        set xstr="lock +^x("
        for i=1:1:30 set xstr=xstr_i set ystr=xstr_")" xecute ystr set xstr=xstr_","
        zsystem "$ydb_dist/lke show -all"
	quit

