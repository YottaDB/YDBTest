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
gtm8167
	set arg1=$tr($j(" ",8192)," ","X")
	; Pass the maximum number of arguments possible
	set jobcomm="job child(arg1"
	for i=1:1:31 set jobcomm=jobcomm_",arg1"
	set jobcomm=jobcomm_")"
	xecute jobcomm
	do ^waitforproctodie($zjob)
	quit

child(a1,a2,a3,a4,a5,a6,a7,a8,a9,a10,a11,a12,a13,a14,a15,a16,a17,a18,a19,a20,a21,a22,a23,a24,a25,a26,a27,a28,a29,a30,a31,a32)
	for i=1:1:32 set @("val=a"_i) write $select($tr($j(" ",8192)," ","X")=val:"TEST-I-PASS for ARG "_i,1:"TEST-E-FAIL Got val:"_val_"for argument: a"_i),!
	quit