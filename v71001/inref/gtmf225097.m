;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fillglobal ;
	set regname=$piece($zcmdline," ",1)
	set basegvname="^"_regname
	set @basegvname=regname
	set ^stopfill=0
	for i=1:1 quit:^stopfill=1  do
	. set gvname=basegvname_i
	. set @gvname=regname
	. for j=1:1:1000 quit:^stopfill=1  do
	. . set @gvname=@gvname_regname
	quit
