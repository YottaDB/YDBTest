;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2007, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zlinktst3(letter)
	ZSYstem $Select($ZVERsion["VMS":"DEL zlinktst2.obj.*",1:"rm zlinktst2.o")
	ZSYstem $Select($ZVERsion["VMS":"copy",1:"cp")_" zlinktst2"_letter_".m zlinktst2.m" ZLink "zlinktst2"
	Quit
