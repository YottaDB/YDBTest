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
gtm8083	;
	;
	; Test that TXTSRCMAT error inside trigger code + TP restarts does not cause SIG-11 anymore
	;
	set ^numjobs=8
	for i=0:1:^numjobs do
	. set file="helper"_i_".m"
	. open file:(newversion)
	. use file
	. write " do ^sstep"
	. for j=1:1:(10+$random(190))  write " set x=$incr(^b("_i_"))",!
	. close file
	. set x=$ztrigger("ITEM","+^a("_i_") -commands=S -xecute=""do ^helper0""")
	set jnoerrchk=1	; do not check *.mje* files as they might contain TXTSRCMAT error that we want to ignore
	; what we are interested in is if any core files happen as a result. that will be caught by the test framework.
	do ^job("child^gtm8083",^numjobs,"""""")
	quit

child	;
	zsystem "\cp -f helper"_jobindex_".m helper0.m"
	for i=1:1:10 set x=$incr(^a(jobindex))
	quit
