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
zycode	;
	set ^a=1
	for i=0:1:40 set ^a(i)=i
	write "# zwrite ^a with the default $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# zyencode with extended reference ^|x.gld|a(1)=^a",!
	zyencode ^|"x.gld"|a(1)=^a
	set $zgbldir="x.gld"
	write "# zwrite ^a  : $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# zyencode with extended reference ^|mumps.gld|a=^|x.gld|a",!
	zyencode ^|"mumps.gld"|a=^|"x.gld"|a
	write "# zydecode with extended reference ^|mumps.gld|a=^|x.gld|a",!
	zydecode ^|"mumps.gld"|a=^|"x.gld"|a
	set $zgbldir="mumps.gld"
	write "# zwrite ^a after the zyencode/zydecode calls : $zgbldir = ",$zgbldir,!
	zwr ^a
	write "# kill ^a - set ^a - zwr ^a : $zgbldir = ",$zgbldir,!
	k ^a
	set ^a=3
	zwr ^a
	set $zgbldir="x.gld"
	write "# kill ^a(1) - set ^a - zwr ^a : $zgbldir = ",$zgbldir,!
	set ^a=2
	k ^a(1)
	zwr ^a
	quit

