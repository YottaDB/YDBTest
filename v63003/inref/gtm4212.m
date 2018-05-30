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
; Generating an m program which prints a string that is too long
;
path249
	write "Creating a 249 length path based off the current directory"
	set bigstring="temp.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<249 do  goto path249+8
	. if l#124=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

