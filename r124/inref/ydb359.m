;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018-2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb359
	set $zinterrupt="do zintr" do ^sstep
	set x=1
	zsystem "$gtm_dist/mupip intrpt "_$j
	set y=2
	set z=3
	write "x = ",x," : y = ",y," : z = ",z,!
	quit

zintr	;
	if $ZJOBEXAM()
	quit
