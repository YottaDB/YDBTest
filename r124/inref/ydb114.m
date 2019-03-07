;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
oper	;
	set ^X=2  set ^A=3  set ^a=10  set ^Z=4  set ^B=5
	set ^X=^X*($random(5)+1)
	set ^A=^A+^Z
	kill ^Z
	kill ^a
	set ^B=(^B-^X)*^A
	quit

peek	;
	write $$^%PEEKBYNAME("sgmnt_data.std_null_coll","DEFAULT"),!
	write $$^%PEEKBYNAME("sgmnt_data.std_null_coll","areg"),!
	write $$^%PEEKBYNAME("sgmnt_data.std_null_coll","breg"),!
