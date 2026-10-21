;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; YDB#1280 : $VIEW("SPSIZE") and $VIEW("SPSIZESORT") must report sizes of 2GiB or more correctly.
;
; Both stages run in one process because stage 2 measures the strings stage 1 sets.
; The strings are 1MiB each, the maximum string length, so that 2100 of them take the stringpool past
; 2GiB with as few local variable nodes as possible.
;
; The expected values are derived as follows.
;   - 2100 strings of 1MiB are 2100 MiB (2202009600 bytes) of live data. Anything else in the stringpool
;     (the few short strings this routine creates) is far below 64KiB, the slack each check allows.
;   - Each check also bounds its values from below in absolute terms, not only relative to another piece.
;     A value that wraps around 2**32 is off by the same amount in every piece, so a comparison between
;     two pieces alone would still pass without the fix.
;
ydb1280	;
	new s,i,v,x,y,p1,p2,mib,live,slack
	set mib=2**20,live=2100*mib,slack=2**16
	;
	write "# Stage 1 : set s(1) to s(2100) each to a different 1MiB string, then write $VIEW(""SPSIZE"")",!
	write "#   expect piece 2 (bytes in use) to be at least 2100MiB, and piece 1 (stringpool size) to be at",!
	write "#   least piece 2, with exactly two comma-separated pieces in all",!
	for i=1:1:2100 set s(i)=$justify(i,mib)
	set v=$view("SPSIZE"),p1=$piece(v,",",1),p2=$piece(v,",",2)
	do chk(p2'<live,"piece 2 is at least 2100MiB",v)
	do chk((p1'<p2)&(p1'<live),"piece 1 is at least piece 2, and so at least 2100MiB",v)
	do chk(2=$length(v,","),"there are exactly two comma-separated pieces",v)
	write !
	;
	write "# Stage 2 : write $VIEW(""SPSIZESORT"") with s(1) to s(2100) still set",!
	write "#   expect piece 2 (space needed with sorting) to be 2100MiB plus less than 64KiB, and piece 1",!
	write "#   (space needed without sorting) to be at least piece 2 and also less than 2100MiB plus 64KiB",!
	set v=$view("SPSIZESORT"),x=$piece(v,",",1),y=$piece(v,",",2)
	do chk((y'<live)&(y<(live+slack)),"piece 2 is 2100MiB plus less than 64KiB",v)
	do chk((x'<y)&(x'<live)&(x<(live+slack)),"piece 1 is at least piece 2 and less than 2100MiB plus 64KiB",v)
	quit
	;
chk(ok,what,v)
	; The actual values vary with the garbage collection mode and the stringpool growth pattern, so they
	; appear in the output only when a check fails.
	write $select(ok:"PASS",1:"FAIL")," : ",what
	write:'ok " (got ",v,")"
	write !
	quit
