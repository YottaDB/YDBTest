;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
ydb480	;
	; Test incrementing 0 value by a 7 digit value (so it is considered floating point) and verifying result
	;
	set ^test=0
	set x="1000000" ; Create string 7 digit value
	set y=$incr(^test,x)
	;
	; Without YDB#480 installed, y is a broken mval with both string and integer flags set. But just comparing
	; x and y just compares the numeric values - which ARE the same. It is the string values that differ. So
	; force y to be re-evaluated as part of the comparison - add a blank to the end to force it to string and
	; then coerce it to numeric to expose the issue.
	;
	if (+(y_" "))'=(+x) do
	. write "FAIL - x and y are not equal but should be",!
	. zshow "*"
	else  write "PASS",!
	quit
