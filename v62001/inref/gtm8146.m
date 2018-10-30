;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2014 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8146	;$ZSEARCH() range and interaction with ZCOMPILE
	;
	new (act)
	if '$data(act) new act set act="use $p write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	; $zsearch(expr,NEG) is valid only if NEG=-1 and invalid for all other negative NEG. Test that below using $random.
	set expect="ZSRCHSTRMCT",x=$zsearch("*.m",-(2+$random(255))) if $increment(cnt) xecute act	; check below range detection
	set x=$zsearch("*.m",256) if $increment(cnt) xecute act	; check above range detection
	set expect="",$zcompile="-noobject -nowarning"
	set:$zversion["VMS" $zcompile=$translate($zcompile,"-","/")	; but $ZCOMPILE doesn't work in VMS
	for strm=0:1:255 do
	. set x=$zsearch("foo",strm),x=$zsearch("*.m",strm)		; clear and grab 1st return
	. zcompile "*.m"						; with a wildcard, it calls op_fnsearch
	. set y=$zsearch("*.m",strm)
	. if y=x,$increment(cnt) xecute act 	; should not reset stream
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
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
