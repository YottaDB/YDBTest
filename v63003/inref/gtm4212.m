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
; Creates 4 paths based on the current directory, of length 230, 231
; <=230 and >=231 and stores them in temp files
;
patheq
	write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	write "a"
	set l=l+1
	if l<$ZCMDLINE do  goto patheq+5
	. if l#25=0  write "/"
	. else  write "a"
	. set l=l+1
	quit


