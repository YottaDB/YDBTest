;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8015	;test unsupported values for gtm_boolean and gtm_side_effects are suppressed
	if '$data(act) new act set act="if $increment(cnt) use $principal write !,$zstatus zshow ""*"""
	new (act),$etrap,$estack
	set $ecode="",$etrap="do ^incretrap";,$zstep="zprint @$zposition zstep into"
	do nogbls^incretrap
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	set fbe=+$ztrnlnm("gtm_boolean"),see=+$ztrnlnm("gtm_side_effects")
	set fb="Standard"=$piece($view("full_boolean")," "),se=$select((see<0)!(see>2):0,1:see)
	if se,'fb,$increment(cnt) xecute act
	set %=2,r=$$times(%,$increment(%))
	if $select(se:6,1:9)'=r,$increment(cnt) xecute act
	if 'r&$$times(1,2),$increment(cnt) xecute act
	if +$get(ex)=fb,$increment(cnt) xecute act
	; We want to do the following in two places where the second place is done with VIEW "NOFULL_BOOLEAN"
	; But this statement is simple enough that the compiler would optimize the xecute out and generate
	; boolean operation code for the xecuted string. That would defeat the purpose of the XECUTE (run-time
	; compilation) and so we store the xecute string in a variable and pass this to the xecute command
	; thereby avoiding the compiler optimization.
	;	xecute "set a=2,b=3,ex=0,x=0&$$times(a,b)"
	;
	set str="set a=2,b=3,ex=0,x=0&$$times(a,b)"
	xecute str
	set:se expect="SEFCTNEEDSFULLB"
	view "nofull_boolean"
	set expect=""
	if fb,'se xecute str if ex xecute act
	if 'se view "full_boolean" xecute "view ""nofull_boolean"" set x=0&$select(a:1,1:0)"
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
	quit
times(a,b)
	set ex='$get(ex)
	quit a*b
err	if $estack write:'$stack !,"error handling failed",$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
