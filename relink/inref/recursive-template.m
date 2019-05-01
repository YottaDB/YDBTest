;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
bar	; version 1 routine
	;
	Write "... version 1 routine",!
	Write $Text(+0),!
	Write $Text(bar+0),!
	ZSHow "S"
	zsystem "cp bar.edit.m baredit.m; $ydb_dist/mumps -nameofrtn=bar baredit.m"
	ZLink "bar.o" ; what if we want to overwr
	;Set $ZROutines="patch.so "_$ZROutines ZLink "bar" ??
###REPLACE:ENTRYREF ;; !!! insert entryref command here !!!
	Write "... version 1 routine again",!
	Write $Text(+0),!
	Write $Text(bar+0),!
	ZSHow "S"
	Quit
	;
foo(x)	; version 1 routine (foo)
	;
	Write "... version 1 routine (foo)",!
	Write $Text(+0),!
	Write $Text(foo+0),!
	ZSHow "S"
	Quit:$Quit "" Quit
