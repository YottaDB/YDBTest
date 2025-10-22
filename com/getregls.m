;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
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
	set reg=""  for  set reg=$view("GVNEXT",reg) quit:reg=""  write reg,!
	quit
count	;
	set numreg=0,reg=""
	for  set reg=$view("GVNEXT",reg) quit:reg=""  do
	. set numreg=numreg+1
	write numreg,!
	quit
randomreglist;
	new regcnt
	if $random(2) write "*",! quit
	set regcnt=0,reg=""  for  set reg=$view("GVNEXT",reg) quit:reg=""  quit:$random(2)  do
	. write:regcnt ","
	. write reg
	. if $incr(regcnt)
	write:regcnt=0 "*"
	write !
	quit
