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
ydb333	;
	set success=0
	write "Do $VIEW(""PROBECRIT"",""DEFAULT"") 20 times to see if CPT (nanoseconds) is not a multiple of 1000 at least once",!
	for i=1:1:100 do  quit:success
	. set critstats=$view("PROBECRIT","DEFAULT")
	. set cptpiece=$piece(critstats,",",1)
	. set cptstat=$piece(cptpiece,":",2)
	. set:(cptstat#1000) success=1
	if success write "PASS : Found CPT stat that is not a multiple of 1000 proving nanosecond (not microsecond) granularity",!
	else       write "FAIL : Found CPT stat always a multiple of 1000 proving nanosecond granularity does not exist",!
	quit
