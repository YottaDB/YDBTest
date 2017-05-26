;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2007-2016 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
c9h03002827
	; Get REPLINSTUNDEF errors since $gtm_repl_instance is undefined
        set incrtrapNODISP=1
	set $ztrap="goto incrtrap^incrtrap"
	zwrite ^a
	;Empty line where incrtrap returns
	zwrite $zs
	set ^b=10
	;Empty line where incrtrap returns
	zwrite $zs
	quit
gtm1	;
	set ^a=1,^b=1
	zsystem "touch midbgupdate1.txt"
	for  quit:$zsearch("endbgupdate1.txt")'=""  h 1
	quit
gtm2	;
	zsystem "touch midbgupdate2.txt"
	for  quit:$zsearch("endbgupdate2.txt")'=""  h 1
	set $ztrap="goto incrtrap^incrtrap"	; to handle REPLINSTNOSHM error
	set ^b=5	; this MIGHT error with REPLINSTNOSHM error if "gtm_custom_errors" env var is not set
	zsystem "touch midbgupdate3.txt"	; signal parent script to proceed to next step
	for  quit:$zsearch("endbgupdate3.txt")'=""  h 1	; wait for source server to be restarted
	set ^b=6	; this should work fine without REPLINSTNOSHM error irrespective of "gtm_custom_errors"
	set ^a=5	; this should work fine without REPLINSTNOSHM error irrespective of "gtm_custom_errors"
	zwrite ^b
	quit
