;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
semcounter
	set ^stop=0,^jobcount=0
	for i=1:1:328 do
	.	for j=1:1:100 do
	.	.	job @("child^semcounter:(output=""semcounter.mjo"_((i-1)*100+j)_""":error=""semcounter.mje"_((i-1)*100+j)_""")")
	.	.	set ^pids((i-1)*100+j)=$zjob
	.	for  quit:^jobcount=(i*100)  hang 1
	quit

child
	if $increment(^jobcount)
	for  quit:^stop  hang 300
	quit

stop
	merge localpids=^pids
	set ^stop=1
	do waitforalltodie^waitforproctodie(.localpids)
	quit
