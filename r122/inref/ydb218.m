;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
test2	;
	VIEW "NOISOLATION":$ZCMDLINE

test1	;
	set num=0
	for i=1:1:1000 do
	.	set glbvar=$piece($ZCMDLINE,",",i)
	.	set num=num+$view("NOISOLATION",glbvar)
	if num=1000 write "------>ydb_app_ensures_isolation is successfully set"
	else  do
	.	write "------>ydb_app_ensures_isolation is not successfully set"
	quit
