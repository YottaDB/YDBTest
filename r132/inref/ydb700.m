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

ydb700	;
	set lf=$c(10)
	write "# Test multi-line trigger with no trailing "">>"". Expect no errors.",!
	write $ztrigger("item","+^a(sub1=0:100) -command=set -name=trig1 -xecute=<<"_lf_" write sub1,!"_lf),!
	write "# Test multi-line trigger with trailing "">>"". Expect no errors.",!
	write $ztrigger("item","+^b(sub1=0:100) -command=set -name=trig2 -xecute=<<"_lf_" write sub1,!"_lf_">>"),!
	write "# Test multi-line trigger with trailing "">>\n"". Expect no errors.",!
	write $ztrigger("item","+^c(sub1=0:100) -command=set -name=trig3 -xecute=<<"_lf_" write sub1,!"_lf_">>"_lf),!
	quit
