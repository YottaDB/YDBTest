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
gtm8036	;test error detection and reporting on some patcode syntax problems - not intended to be excuted
	;
	write "b"?1(1"a",1"a".1(1"a".(1A)1"a")
	write "b"?1(1"a",1"a".1(1"a".(1A)1"a"),"b"
	write "b"?1(1"a",1"a".1(1"a".(1A)1"a")_"b"
	quit
