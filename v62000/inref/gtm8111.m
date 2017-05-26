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
gtm8111	;
text	;
	do lnknwt
	write "### $text begin",!
	write $text(lab^src),!
	write "### $text done",!
	quit
	;
lnknwt	; link, then overwrite source before we get to $TEXT/ZPRINT
	set $zro="."
	zlink "src"
	zsystem "cp src2.m src.m"
	quit
