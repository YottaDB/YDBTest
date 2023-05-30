;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                               ;
; Copyright (c) 2021-2023 YottaDB LLC and/or its subsidiaries.       ;
; All rights reserved.                                          ;
;                                                               ;
;       This source code contains the intellectual property     ;
;       of its copyright holder(s), and is made available       ;
;       under a license.  If you do not know the terms of       ;
;       the license, please stop and do not read further.       ;
;                                                               ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
	; The below entryrefs are helper programs used by "testI()" function in "r126/inref/ydb429.sh".
	; They assume a 3-region setup and use 3 global names that map to each of the 3 regions.
ydb426	;
	quit

setgblsallregions	;
	for gblname="^default","^%ydboctotmp","^%ydbAIMtmp" do
	. write "; Set ",gblname,"=",$incr(^counter)," : Global maps to ",$view("REGION",gblname)," region",!  set @gblname=^counter
	quit

bkgrnd	;
	set jmaxwait=0	; to background
	do ^job("child^ydb429",1,"""""")
	; Wait for child^ydb429 to have finished at least one iteration of the for loop as that is what
	; verifyaftercrash^ydb429 (invoked after the crash/rollback) relies on. Hence the check for ^%ydbAIMtmp
	; as it is the last global updated in the "for" loop in child^ydb429.
	for  quit:$data(^%ydbAIMtmp(2))  hang 0.001
	quit

child	;
	set ^child=$job
	for i=1:1 set (^default(i),^%ydboctotmp(i),^%ydbAIMtmp(i))=i view "jnlwait" hang 0.01
	quit

verifyaftercrash;
	for gblname="^default","^%ydboctotmp","^%ydbAIMtmp" do exist(gblname)
	quit

exist(gblname)
	write "Global ",gblname," ",$select($data(@gblname):"exists",1:"does not exist"),!
	quit

