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

gtm8951
	write "$TEXT = ",$TEXT(^temp),!
	write "ZPRINT OUTPUT:",!
	ZPRINT ^temp
	write "--------------Updating temp.m file--------------------",!
	zsystem "\cp -f newtemp.m temp.m"
	zrupdate "temp.o"
	write "$TEXT = ",$TEXT(^temp),!
	write "ZRINT OUTPUT:",!
	ZPRINT ^temp
	quit

