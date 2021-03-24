;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb692	;
        for dividend="3;","0;","-2;",";","-2.555;","3.8923;" do
	. ; Choose only interesting powers of 10 to limit reference file size
        . for power=-43,-24,-6,-1,0,1,6,9,46 do
        . . set divisor=10**power
        . . do modulo(dividend,divisor)
        . . do modulo(dividend,-divisor)
        . . do modulo(dividend,divisor+.852)
        . . do modulo(dividend,-divisor-.333)
        quit

modulo(dividend,divisor)
        write $zwrite(dividend),"#",divisor,"=",dividend#divisor,!
        quit

