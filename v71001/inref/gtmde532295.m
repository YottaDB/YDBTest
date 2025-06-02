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
;
; Partially copied from v70002/inref/gtmf135414.m
split;
	kill ^x
	do ^job("child^gtmf135414",4,"""""")
	quit
	;
child;
	tstart ()
	for i=1:1:10000 set ^x($job)=$j(i,1+$random(16))
	tcommit
	quit
	;

