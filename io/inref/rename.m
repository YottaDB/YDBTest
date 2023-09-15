;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
; Portions Copyright (c) Fidelity National			;
; Information Services, Inc. and/or its subsidiaries.		;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

rename; Test the deviceparameter RENAME
        set file="rename.txt"
        set filed="renamed.txt"
        set s1=$ZSEARCH(file)
        set sd1=$ZSEARCH(filed)
        open file:(NEWVERSION)
        use file
        write "BLAH",!
        set s2=$ZSEARCH(file)
        set sd2=$ZSEARCH(filed)
	close file:(RENAME=filed)
        use $PRINCIPAL
        set s3=$ZSEARCH(file)
        set sd3=$ZSEARCH(filed)
	set pass=0
	if ""=s1,""=s3,""'=s2 set pass=1
	if ""=sd1,""'=sd3,""=sd2 set pass=1
	if 1=pass write "PASS",!
        else  write "FAIL",! zwr
	open filed
	use filed
	do readfile^filop(filed,0)
        q

