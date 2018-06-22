;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;
parent
	set $etrap="do incrtrap^incrtrap"
	write "# Attempting to ZBREAK the trigger (Expect a RESTRICTEDOP Error)",!
	ZBREAK ^triggered#:"Write ""ZBREAK Trigger was not ignored"",!"
	ZBREAK child^gtm8842:"Write ""ZBREAK within trigger was not ignored"",!"

	write "# Setting off a trigger function with ZBREAK break points and ZSTEPS",!
	set ^X=1
	write "ZSTEP Successfully Ignored",!
	write "TEST PASSED"
	quit

trigger
	do child^gtm8842
	write "ZBREAK Successfully Ignored",!
	quit

child
	ZSTEP INTO:"Write ""ZSTEP within trigger was not ignored"",!,""TEST FAILED""  break"
	quit
