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
longstring
	set x="longstring.txt"
	open x
	use x
	for i=1:1:$zcmdlne do
	. write "a"
	quit

test1
	set ^X=$ztrnlnm("longstring")
	quit

test2
	set ^X($ztrnlnm("longstring"))=1
	quit

test3
	set x=$ztrnlnm("longstring")
	write "Successfully set variable",!
	quit

test4
	set x($ztrnlnm("longstring"))=1
	write "Successfully set variable",!
	quit

