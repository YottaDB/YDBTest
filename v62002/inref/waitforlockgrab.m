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
waitforlockgrab(lockname)
	set timeout=300
	set return=0
	set file="lke.out"
	for i=1:1:timeout quit:return=1  do
	.   zsystem "lke show -wait >& "_file
	.   quit:1=$$checkrequest()
	.   hang 1
	write:i=timeout "TEST-E-FAIL No process is waiting on lock "_lockname
	quit

checkrequest()
	open file
	use file
	set return=0
	for  read line quit:$zeof  if (line[lockname_" Request PID= ") set return=1 quit
	close file
	quit return