;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8115	; test that FOR doesn''t cause issues with BREAK and NEW and exclusive NEW and NEW all don't for zstep and zbreak
	;
	new (act)						; define act before invocation to change default error action
	if '$data(act) new act set act="use $p write !,$zpos,! zprint @$zpos zshow ""v"""	;set up default error action
	new $etrap,$estack					; error handling initializatopn
	set $ecode="",$etrap="goto err",$zstatus="",zl=$zlevel
	for i=1:1 break:i=3  set j=i quit:2=i			; conditional BREAK with j first used after it
	if 2'=i!(j'=i),$increment(cnt) xecute act		; check that it worked
	for i=1:1 new:i=2 (act,cnt,i)  quit:2=i  set j=i	; conditional NEW with j first used after it
	if 2'=i!$data(j),$increment(cnt) xecute act		; check that it worked
	zbreak zstept1:"zstep into:""new (act,cnt)"""		; insert ZSTEP that does an exclusive NEW
	zbreak zstept2:"zstep into:""new"""			; insert ZSTEP that does a NEW all
	zbreak zbtst1:"new (act,cnt)"				; insert ZBREAK that does an exclusive NEW
zbtst1	if $data(i),$increment(cnt) xecute act			; check that the immediately prior ZBREAK worked
	set i=1,$zmaxtptime=0					; abuse $ZMAXTPTIME as a flag not subjest to NEW
	zbreak zbtst2:"new"					; insert ZBREAK that does a NEW all
	do  if $zmaxtptime if $increment(cnt) xecute act	; check that the immediately prior ZBREAK worked -
zbtst2	. if $data(i) set $zmaxtptime=1				; nest this one up a level so we don't lose act and cnt permanently
zstept1	zcontinue		; the ZSTEP affects the next line and GT.M collapses lines with no code so this is a placeholder
	if $data(i),$increment(cnt) xecute act			; check the ZSTEP with the exclusive NEW
	set i=1,$zmaxtptime=0					; abuse $ZMAXTPTIME as a flag not subjest to NEW
zstept2	do  if  if $increment(cnt) xecute act			; check the ZSTEP with the NEW all
	. if $data(i) set $zmaxtptime=1				; nest this one up a level so we don't lose act and cnt permanently
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0),!
	quit
	; error handler to move on after an expected error and report anything else
err	if $estack write:'$stack !,"error handling failed",$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within error
