;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2002, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
test12	;
	;
	; Test the following scenario.
	; 	a) primary error happens with $ZTRAP enabled
	; 	b) the error handler goes into a frame that has $ETRAP enabled
	; 	c) now an error occurs
	; 	d) the $ETRAP handler now invokes a routine that has another error.
	;
x	;
	set cnt=0
	s $ztrap="do ztr"
	write x
	quit
ztr	;
	write "in ztr",!
	set x=1
	n $ztrap
	s $etrap="do etr"
	write 1/0
	quit
etr	;
	write "in etr",!
	set cnt=cnt+1
	if cnt<4 quit 1
	set $ecode=""
	quit
