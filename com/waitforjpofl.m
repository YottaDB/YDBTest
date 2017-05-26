;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitforjpofl
	new poolsize,initwriteaddr,curwriteaddr,timeout,i
	set timeout=300
	do getcurjp(.initwriteaddr,.poolsize)
	for i=1:1:timeout  hang 1  do getcurjp(.curwriteaddr)  quit:curwriteaddr>(initwriteaddr+poolsize)
	write:i=timeout "TEST-E-TIMEOUT, waitforjpofl took longer than "_timeout_" seconds",!
	open "waitforjpofl.out":APPEND  use "waitforjpofl.out"  write $h,!  zwrite  close "waitforjpofl.out"
	quit

getcurjp(writeaddr,poolsize)
	new p,i,line,fields
	set p="jnlpool show pipe"
	open p:(command="$MUPIP replic -source -jnlpool -show":readonly)::"PIPE"
	use p
	for i=1:1 quit:$zeof  read line(i)  do process^replinst(line(i),.fields)
	close p
	set writeaddr=+fields("CTL","Absolute Write Offset")
	set poolsize=+fields("CTL","Journal Pool Size (in bytes)")
	quit
