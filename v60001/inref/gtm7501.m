;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm7501	;test exponentiation, in particular for appropriate behavior with negative values
	;
	new (act)
	if '$data(act) new act set act="use $p write !,i,?5,j,?10,k,?15,x,?50,i**(j/k)"
	new $etrap,$estack
	set $ecode="",$etrap="do err"
	for i=0:.1:3 for j=-3:.1:3 for k=-3:.1:-.1,.1:1:3 if i&(0'>(j/k)) set x=i**(j/k) if i**(j/k)'=x,$increment(cnt) Xecute act
	for l=1:1:10000 set i=$random(10000)+1,j=$r(10)+1-5,k=$random(10)-5 if k do
	. set x=i**(j/k) if i**(j/k)'=x,$increment(cnt) Xecute act
	Set j=1			;Note, in line below 45 causes errors in VMS prior to V60001. Previous max was 35
	for l=1:1:10000 set i=$random(10)+1,k=$random(45)+1,x=i**k i x**(1/k)'=i,$increment(cnt) Xecute act
	write !,$select('$get(cnt):"No",1:cnt)," errors from ",$text(+0),!
	quit
err	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
