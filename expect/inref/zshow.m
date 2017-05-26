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
zshow(useflag);
	if useflag do
	.	use $p:(empterm) zshow "d":DEV write "EMPTERM ",$select(DEV("D",1)["EMPTERM":"exists",1:"Does not exist"),!
	.	use $p:(noempterm) zshow "d":DEV write "EMPTERM ",$select(DEV("D",1)["EMPTERM":"exists",1:"Does not exist"),!
	zshow "d":DEV write "EMPTERM ",$select(DEV("D",1)["EMPTERM":"exists",1:"Does not exist"),!
	quit
