;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2001-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MYLABEL:
	write $TEXT(M),!
	write $TEXT(MYLABEL),!
	write $TEXT(FOO),!
	write $text(a),!,$text(b),!,$text(c),!,$text(d),!,$text(e),!
	quit
abc	; wrong
bc	; wrong
cbad	; wrong
doff	; wrong
eor	; wrong
a	; right
b()	; right
c;	; right
d:	; right
e
	; the code below is not executed, but should compile properly in dbg
	kill ^[$$gld^gtm8549]b
	quit
gld()
	quit "mumps.gld"
	;
M; This is a label
