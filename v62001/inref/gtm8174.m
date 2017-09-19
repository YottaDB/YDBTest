;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
; Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.	     	  	     			;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8174	;test that raising 0 to a negative power gives an DIVZERO error
	;
	new (act)
	if '$data(act) new act set act="use $p write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	for a=-1:.0001:1 f b=1E10,123456789,123456.789,.123456789,.123456789E10 do
	. if 0<=a!'(b#1) set x=a**b quit
	. new $estack
	. set expect="NEGFRACPWR"
	. set x=a**b if $increment(cnt) xecute act
	. set x=a**-b if $increment(cnt) xecute act
	. kill expect
	set expect="DIVZERO"
	; Use variable in the ** operator to avoid compiler from evaluating literal expressions and erroring at compile time
	for exp=-1,-1E10,-123456789,-123456.789,-.123456789,-.123456789E10  do
	. set x=0**exp if $increment(cnt) xecute act
	. set x=-0**exp if $increment(cnt) xecute act
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
	quit
err	if $estack write:'$stack !,"error handling failed",$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
