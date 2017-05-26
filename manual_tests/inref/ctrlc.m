;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2004-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ctrlc	;
	set x=0,i=0,a=0
	zsystem "gde exit"
	zsystem "mupip create"
	zsystem "mupip set -lock=5000 -region ""*"""
	for i=1:1:10000 lock +a(i)
	for i=1:1:100000 set a(i)=$j(i,100)
	do sstep^ctrlc
	set x=0
	for i=1:1:10000000  SET x=x+1
	quit
sstep   ;
	set $zstep="zprint @$zpos  zstep into"
	zbreak sstep+3^ctrlc:"zstep i"
	write !,"Stepping STARTED",!
	quit
validate;
	write "Checking test status",!
	set z=$order(y("V",""),-1)
	if (z=100002)!($data(x)[0)!(x=10000000) set status="FAIL"
	else  set status="PASS"
	write status
	quit
