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
path231
	;assumes path is already less than 231 characters long
	set bigstring="temp231.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<231 do  goto path231+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

path230
	;assumes path is already less than 230 characters long
	set bigstring="temp230.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<230 do  goto path230+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

pathge231
	set x=231+$random(10)+1
	set bigstring="tempge231.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<x do  goto pathge231+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit

pathle230
	set x=230-$random(10)-1
	set bigstring="temple230.out"
	open bigstring
	use bigstring write $ZDIRECTORY
	set l=$length($ZDIRECTORY)
	use bigstring write "a"
	set l=l+1
	if l<x do  goto pathle230+8
	. if l#25=0 use bigstring write "/"
	. else  use bigstring write "a"
	. set l=l+1
	quit


