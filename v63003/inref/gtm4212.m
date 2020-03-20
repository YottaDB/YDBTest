;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Creates a path based on current directory with a number of characters
; specified by the parameter
;
genlongpath
	write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	write "a"
	set l=l+1
	if l<$ZCMDLINE do
	. for i=1:1:$ZCMDLINE-l do
	. . if i#25=0  write "/"
	. . else  write "a"
	quit


