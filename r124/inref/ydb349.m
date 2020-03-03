;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb349	;
	set ^x=$justify(1,1+$random(2**12))
	quit

genfillfactor()	;
	write $random(101)	; return a fill_factor number ranging from 0% to 100%
	quit

genreservedbytes	;
	write $random(4000+1)	; return a reserved_bytes number ranging from 0 to 4000 (maximum reserved bytes for 4kb block size)
	quit
