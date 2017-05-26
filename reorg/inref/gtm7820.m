;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7820;
	set killxglobal=+$piece($zcmdline," ",1)
	set spanreg=+$piece($zcmdline," ",2)
	set ^x=$j(0,200)
	if spanreg for i=1:1:3000 set ^x(1,i)=$j(i,200),^x(10,i)=$j(i,200),^x(40,i)=$j(i,200)
	else	   for i=1:1:10000 set ^x(1,i)=$j(i,200)
	for i=1:1:10 set ^xx(i)=$j(i,200)
	if killxglobal kill ^x
	kill ^x(1)
	if spanreg kill ^x(40),^x(10)
	kill ^xx
	quit

