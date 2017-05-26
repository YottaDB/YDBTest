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
gtm7519	;
	set numjobs=8
	do ^job("child^gtm7519",numjobs,"""""")
	quit

child	;
	set val=$j("",300)		; each node fills up a whole GVT leaf block
	tstart ():serial
	set (^x(1),^x(2))=val
	tcommit
	kill ^x
	quit
