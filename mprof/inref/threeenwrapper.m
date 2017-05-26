;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2011, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is a wrapper for the external-call testing with MPROF. This script
; calls through to threeen.c and is itself invoked by D9L06002815.
threeenwrapper ;
	view "TRACE":1:"^threeentrc"
	read input
        set limit=+input
	set hor1=$H
	do &s3nP1(limit)
	set hor2=$H
	set ^hor=hor1_" - "_hor2
	view "TRACE":0:"^threeentrc"
	quit
