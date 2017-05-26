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
gtm7740;
	;
	; 'x' is a local variable with only lower case letters in its value.
	; This subtest uses reverse collation. In this reverse collation trasfromation,
	; A char with ASCII value 'X' is transformed to 255 - 'X'.
	; For Ex: $char(97) is transformed into $char(255-97).
	set x="" for i=0:1:1000 set x=x_$char(255-(97+(i#26)))
	write $view("YGDS2GVN","GTM"_$c(0)_$char(255)_x_$c(0)_$c(0),1)
	halt
