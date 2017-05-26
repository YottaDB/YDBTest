;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
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
