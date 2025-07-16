;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

gtmde559768 ;
	set $ztrap="goto incrtrap^incrtrap"
	set incrtrapNODISP=1    ; so incrtrap^incrtrap does not display $ZSTATUS for each error
	for j=1:1:10 do
	. write !
	. set stor1=$zallocstor
	. write "# Run the pattern match label 'pat' "_j_" times",!
	. for i=1:1:j do pat
	. set stor2=$zallocstor
	. if j>1  do
	. . write "# Expect allocation increase = 0 (previously, increase was > 0):",!
	. else  do
	. . write "# Expect allocation increase > 0:",!
	. write "Allocation increase for [",j,"] iterations = ",stor2-stor1," ("_stor2_"-"_stor1_")",!
	quit

pat     ;
	set x="abcd"_i?@".3(1N,2U,literal)"
	quit
