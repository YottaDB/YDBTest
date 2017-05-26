;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
undefindr ; version 1
	view "LINK":"RECURSIVE"
	set %=%incr(@"x($$f)") ; intentional typo causes UNDEF error
	do lab
	quit

lab	write "lab v1",!
	quit

f()	zlink "undefindr.edit"
	quit 0
