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
; This module is derived from FIS GT.M.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;Testing zsystem from inside triggers, technically this is a no no
	;see the trigzsyxplode test for more information
trigzsy
	do ^echoline
	do basic
	do ^echoline
	do nest
	do ^echoline
	do chain
	do ^echoline
	quit

basic	write "Test zsystem from inside a trigger",!
	set x=$ztrigger("item","+^a -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva """)
	set x=$ztrigger("item","+^b -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva """)
	set (^a,^b)="date +%d-%b-%Y_%H:%M:%S"
	quit

nest
	write !
	write "Testing zsystem inside nested triggers",!
	set x=$ztrigger("item","+^c -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva s ^a=^b""")
	set ^c="date +%Y%m%d_%H%M"
	quit

chain
	write !
	write "Testing zsystem inside chained and nested triggers",!
	set x=$ztrigger("item","+^c -command=S -xecute=""w ?10,$r,$c(61),$ztva,! zsy $ztva s ^b=^a""")
	set ^c="date +%D_%H:%M"
	quit

