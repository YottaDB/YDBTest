;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8137
	set ^stop=0,^alivechild=0,nchild=5
	for i=1:1:nchild do
	.   set errorout="errorchild.erx"_i
	.   set stdout="errorchild.outx"_i
	.   job @("child^gtm8137:(output="""_stdout_""":error="""_errorout_""")")
	.   set joblist(i)=$zjob
	write "# Verify the CRITSEMFAIL is in the output",!
	zsystem "source $gtm_tst/$tst/u_inref/critsemfail_exists.csh"
	set ^stop=1
	do waitforalltodie^waitforproctodie(.joblist)
	quit
child
	set timeout=30
	write "PID="_$job
	if $incr(^alivechild)
	for i=1:1:timeout quit:^stop  hang 1
	write:i=timeout "TEST-E-FAIL "_$j_" timed out",!
	quit
checkftokhaltedflag
	write $$^%PEEKBYNAME("node_local.ftok_counter_halted","DEFAULT")
	quit
checkaccesshaltedflag
	write $$^%PEEKBYNAME("node_local.access_counter_halted","DEFAULT")
	quit
