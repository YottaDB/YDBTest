;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8063
	; Open a socket to see what descriptor number it gets.
	; If it were to get 0, 1, or 2, that would be bad.
	; It is 3 on most platforms, 6 on Solaris Zones.
	set fn="closefds_"_$ztrnlnm("OPTNUM"),out=fn_".out",err=fn_".err",maxstdfd=2,timeout=120
	set $etrap="zshow ""*"":zs  open err  use err  zwrite zs  halt"
	open "s":IOERROR="trap"::"SOCKET"
	open "s":CONNECT="localhost:22:TCP":timeout:"SOCKET"
	else  open err  use err  write "TEST-E-TIMEOUT: connect took longer than "_timeout_" seconds",!  halt
	ZSHOW "D":zsd
	open out
	use out
	zwrite zsd
	write $select(+$piece(zsd("D",4),"DESC=",2)>maxstdfd:"PASS",1:"FAIL"),!
	quit
