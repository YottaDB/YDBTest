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
path249
	;assumes path is already less than 249 characters long
	write "Creating a 249 length path based off the current directory"
	set bigstring="temp.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<248 do  goto path249+9
	. if l#124=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	write "/"
	quit

