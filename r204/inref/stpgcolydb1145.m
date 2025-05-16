;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

stpgcolydb1145	;
	quit

spSizeSortUnshared
	; This is example 1 of https://gitlab.com/YottaDB/DB/YDB/-/issues/1145#note_2507097811
	do Unshared
	write $view("spsizesort"),!
	quit

spSizeSortShared
	; This is example 2 of https://gitlab.com/YottaDB/DB/YDB/-/issues/1145#note_2507097811
	do Shared
	write $view("spsizesort"),!
	quit

stpgcolUnshared
	do Unshared
	view "stp_gcol"
	write $piece($view("spsize"),",",2),!
	quit

stpgcolShared
	do Shared
	view "stp_gcol"
	write $piece($view("spsize"),",",2),!
	quit

Unshared
	for i=1:1:100000 set x(i)=$j(1,1000)
	quit

Shared
	set x=$j(1,1000) for i=1:1:100000 set x(i)=x
	quit

gctest2
	; This is Test 2 of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1668#note_2445424537
	for i=1:1:10000000 set x(i)=$justify(1,20)
	quit

gctest2verify
	set cputim0=+$piece($zcmdline," ",1)
	set cputim1=+$piece($zcmdline," ",2)
	if ('cputim0)!('cputim1) write "FAIL : At least one of cputim0 =[",cputim0,"] or cputim1 [",cputim1,"] is 0.",!
	if (0.95*cputim0)>cputim1  write "PASS from gctest2verify",!
	else                      write "FAIL from gctest2verify : cputim1=[",cputim1,"] is not 5% (or more) less than cputim0=[",cputim0,"]",!
	quit

