;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
zchmod	;;; Test of chmod inside of M process
	zsystem "chmod 444 mumps.dat"
	zsystem "$gtm_tst/com/lsminusl.csh mumps.dat"
	quit
mjl	zsystem "chmod 444 mumps.mjl"
	zsystem "$gtm_tst/com/lsminusl.csh mumps.mjl"
	quit
bckdat	zsystem "chmod 666 mumps.dat"
	zsystem "$gtm_tst/com/lsminusl.csh mumps.dat"
	quit
bckjnl	zsystem "chmod 666 mumps.mjl"
	zsystem "$gtm_tst/com/lsminusl.csh mumps.dat"
	quit
