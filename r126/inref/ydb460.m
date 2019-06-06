;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; generates a line of M code that is 32766 (32KiB-2) characters long
ydb460 ;
	set len=32766

	; longline generation
	set str=" "
	set i=0
	set strLen=0
	for  set apd="set a("_i_")="_i_" " quit:($length(str)+$length(apd))>(len-$length(apd))  set str=str_apd set i=i+1
	set pad=len-$length(str)-$length(apd)
	set numSet=i
	for i=1:1:pad set str=str_" "
	set str=str_apd
	write str
	write !," set i="_numSet

	; longline check
	set str=" set pass=1 for j=0:1:i if $get(a(j))'=j set pass=0 write ""a(""_j_"")=""_$get(a(j))_"" should be ""_j,!"
	write !,str
	write !," if pass write ""PASS"",!"
	write !," else  write ""FAIL"",!"


	quit
