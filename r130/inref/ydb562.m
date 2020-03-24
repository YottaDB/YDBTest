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

ydb562	;
	; Need to use `^incrtrap` to proceed to next M line in case of errors (expected in this test)
	; Since the error in this test occurs when `$zroutines` is set to an invalid directory, we need to make
	;	sure it is set to a valid value before `^incrtrap` is accessed, hence the `set $zroutines=oldzroutines`.
	set oldzroutines=$zroutines
	set $ztrap="set $zroutines=oldzroutines goto incrtrap^incrtrap"
	set path=""
	for i=1:1:5 do
	. set path=path_"."
	. write " --> Test : set $zroutines="""_path_"""",!
	. set $zroutines=path
	. kill dummy
	quit
