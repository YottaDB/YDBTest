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

manygbls ;
	for i=1:1:20 do
	. for j=1:1:20 do
	. . set gvname="^"_$char(96+i)_$char(96+j)_"ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	. . set @gvname=0
	. . kill:$random(100) @gvname
	quit
