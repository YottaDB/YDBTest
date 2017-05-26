;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8539 ;
	; Generate some updates. Display number of updates per second and journal file size.
	;
        set curh=$h,curi=0
        for i=1:1:5000000 set ^x=i if $h'=curh  do
        . write "$h = ",$h," : # of updates = ",i-curi," : jnl_file_size = 0x"
        . write $$FUNC^%DH($$^%PEEKBYNAME("jnl_buffer.freeaddr","DEFAULT")),!
        . set curh=$h,curi=i
        quit
