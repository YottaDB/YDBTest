;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

randarg	; Echo one of the CLI args selected randomly
	; Typical usecase: generate synonims for CLI args
	; Example:
	;   set POS = `$gtm_dist/mumps -run randarg 1 2 999 y Y yes Yes YES t T tr Tr TR true True TRUE`
	;   set NEG = `$gtm_dist/mumps -run randarg 0 n N no No NO f F fa Fa FA false False FaLSe FALSE`
	;
	for count=1:1:99 quit:$piece($zcmdline," ",count)=""
	set count=count-1
	if count=0 write "TEST-E-BADARGS: word list must be specified",! quit
	write $piece($zcmdline," ",1+$random(count)),!
	quit
