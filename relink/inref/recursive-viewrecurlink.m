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
viewrecurlink
	Set $ETRAP="Do etr"
	ZSHow "R"
	View "LINK":"RECURSIVE"
	Write $View("LINK"),!
	Write $View("RTNCHECKSUM","viewrecurlink"),!
	zsystem "cp viewrecurlink.edit.m viewrecurlinkedit.m; $ydb_dist/mumps -nameofrtn=viewrecurlink viewrecurlinkedit.m"
	ZLink "viewrecurlink.o"
	Do recurse^viewrecurlink
	View "LINK":"NORECURSIVE"
	Write $View("LINK"),!
	Write $View("RTNCHECKSUM","viewrecurlink"),!
	zsystem "cp viewrecurlink.edit.m viewrecurlinkedit.m; $ydb_dist/mumps -nameofrtn=viewrecurlink viewrecurlinkedit.m"
	ZLink "viewrecurlink.o"	; expect LOADRUNNING error
	Write "DONE",!
	Quit

etr
	Write $Piece($ZSTATUS,",",3),!
	Set $ECODE=""
	Quit
