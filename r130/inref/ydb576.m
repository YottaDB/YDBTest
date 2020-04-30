;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb576	;
	quit

trig	;
        new expect,actual
        set actual=$piece($ztvalue,"|",1)
        set expect=$select($ztvalue="abc|d":"abc",$ztvalue="e|fgh":"e",1:"")
        if actual'=expect do
        . write "TEST-E-FAIL : $ztvalue=",$ztvalue," : $piece($ztvalue,""|"",1) : Actual=",actual," : Expect=",expect,!
	quit
