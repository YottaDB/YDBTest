;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Writing the output of zparse for DIRECTORY NAME TYPE ALL for various symbolically linked files

testzparse
	For i="DIRECTORY","NAME","TYPE","" Write $ZPARSE($zcmdline,i,"","","SYMLINK"),!
	quit

nosymlink
	For i="DIRECTORY","NAME","TYPE","" Write $ZPARSE($zcmdline,i),!
	quit
