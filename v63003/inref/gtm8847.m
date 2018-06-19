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
test1
	write:($ZCMDLNE=$ZSTRPLLIM) "$gtm_string_pool_limit=$ZSTRPLLIM"
	quit

test2
	do ^sstep
	set x="abcd"
	set $ztrap="goto incrtrap^incrtrap"
	set $ZSTRPPLIM=100
	for  set x=x_x
	set x=x_x
	quit

test3
	set $ztrap="goto incrtrap^incrtrap"
	write "$ZSTRPPLIM=",$ZSTRPLLIM,!
	set x="abcd"
	for  set x=x_x
	set $ZSTRPPLIM=-1
	write "$ZSTRPPLIM=",$ZSTRPLLIM,!
	set x="abcd"
	for  set x=x_x
	quit
