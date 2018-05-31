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
;
;
path246
	;assumes path is already less than 246 characters long
	write "Creating a 246 length path based off the current directory"
	set bigstring="temp.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<238 do  goto path246+9
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

