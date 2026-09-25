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
; All three stages run in one process because each one depends on the stringpool the previous one left.
; The strings are 1MiB each, the maximum string length, so that 2100 of them take the stringpool past
; 2GiB with as few local variable nodes as possible.
;
; The expected values are derived as follows.
;   - 2100 strings of 1MiB are 2100 MiB (2202009600 bytes) of live data. Anything else in the stringpool
;     (the few short strings this routine creates) is far below 64KiB, the slack each check allows.
;   - The stringpool never shrinks, so its size after the KILL is the size it had in stage 1.
;   - At the end of a garbage collection, the level at which the next one is triggered is set to three
;     times the space requested plus the space in use (STP_SPACE_USED_MULTIPLIER in sr_port/stp_parms.h),
;     and piece 3 of $VIEW("SPSIZE") is the stringpool size minus that level. In stage 3 the collection is
;     triggered by a request for 1MiB while 1MiB is still live, so piece 1 minus piece 3 is 3 x 2MiB.
;   - Each check also bounds its values from below in absolute terms, not only relative to another piece.
;     A value that wraps around 2**32 is off by the same amount in every piece, so a comparison between
;     two pieces alone would still pass without the fix.
;
ydb1280	;
	new s,i,v,x,y,p1,p2,p3,stage1size,mib,live,slack
	set mib=2**20,live=2100*mib,slack=2**16
	;
	write "# Stage 1 : set s(1) to s(2100) each to a different 1MiB string, then write $VIEW(""SPSIZE"")",!
	write "#   expect piece 2 (bytes in use) to be at least 2100MiB, piece 1 (stringpool size) to be at least",!
	write "#   piece 2, and piece 3 to be zero or more",!
	for i=1:1:2100 set s(i)=$justify(i,mib)
	set v=$view("SPSIZE"),p1=$piece(v,",",1),p2=$piece(v,",",2),p3=$piece(v,",",3)
	do chk(p2'<live,"piece 2 is at least 2100MiB",v)
	do chk((p1'<p2)&(p1'<live),"piece 1 is at least piece 2, and so at least 2100MiB",v)
	do chk(p3'<0,"piece 3 is zero or more",v)
	set stage1size=p1
	write !
	;
	write "# Stage 2 : write $VIEW(""SPSIZESORT"") with s(1) to s(2100) still set",!
	write "#   expect piece 2 (space needed with sorting) to be 2100MiB plus less than 64KiB, and piece 1",!
	write "#   (space needed without sorting) to be at least piece 2 and also less than 2100MiB plus 64KiB",!
	set v=$view("SPSIZESORT"),x=$piece(v,",",1),y=$piece(v,",",2)
	do chk((y'<live)&(y<(live+slack)),"piece 2 is 2100MiB plus less than 64KiB",v)
	do chk((x'<y)&(x'<live)&(x<(live+slack)),"piece 1 is at least piece 2 and less than 2100MiB plus 64KiB",v)
	write !
	;
	write "# Stage 3 : KILL s, then set x to a new 1MiB string repeatedly until a garbage collection sets",!
	write "#   piece 3 of $VIEW(""SPSIZE"") to something other than zero",!
	write "#   expect piece 1 to be unchanged from stage 1, piece 2 to be 2MiB plus less than 64KiB, piece 1",!
	write "#   minus piece 3 to be 6MiB plus less than 192KiB, and so piece 3 to be at least 2093MiB",!
	kill s
	for i=1:1:10000 set x=$justify(i,mib),v=$view("SPSIZE") quit:$piece(v,",",3)'=0
	set p1=$piece(v,",",1),p2=$piece(v,",",2),p3=$piece(v,",",3)
	do chk((p1=stage1size)&(p1'<live),"piece 1 is unchanged from stage 1, and so at least 2100MiB",v)
	do chk((p2'<(2*mib))&(p2<((2*mib)+slack)),"piece 2 is 2MiB plus less than 64KiB",v)
	do chk(((p1-p3)'<(6*mib))&((p1-p3)<((6*mib)+(3*slack))),"piece 1 minus piece 3 is 6MiB plus less than 192KiB",v)
	do chk(p3'<(2093*mib),"piece 3 is at least 2093MiB",v)
	quit
	;
chk(ok,what,v)
	; The actual values vary with the garbage collection mode and the stringpool growth pattern, so they
	; appear in the output only when a check fails.
	write $select(ok:"PASS",1:"WRONG")," : ",what
	write:'ok " (got ",v,")"
	write !
	quit
