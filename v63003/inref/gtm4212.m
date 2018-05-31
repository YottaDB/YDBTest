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
path235
	;assumes path is already less than 235 characters long
	set bigstring="temp235.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<235 do  goto path235+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

path236
	;assumes path is already less than 236 characters long
	set bigstring="temp236.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<236 do  goto path236+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

pathle235
	set x=235-$random(10)-1
	set bigstring="temple235.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<x do  goto pathle235+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

pathge236
	set x=235+$random(10)+1
	set bigstring="tempge236.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<x do  goto pathge236+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit


