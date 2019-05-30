;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
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
gtm7779	; generate some contention to show the effect on crit data in gvstats
	; this test contains nothing UNIX specific but is in inref_u because the feature it's testing is UNIX specific
	; We need to trigger some crit conflicts. Create contention by jobbing off processes that do concurrent updates.
	new (act,debug)
	if '$data(act) new act set act="use $principal write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	set gblcnt=100,numjobs=20,queslots=1024
	set nobefore=+$ztrnlnm("gtm_test_jnl_nobefore")
	kill ^x
	set ^stop=0
	set jmaxwait=0
	view "gvsreset"
	do ^job("activity^gtm7779",numjobs,""""_gblcnt_"""")
	for i=1:1 set ^x($job,$justify(i,200))=$j(i,2000)  if '(i#gblcnt) do  quit:^stop
	. view "epoch"
	. zshow "g":val
	. do in^zshowgfilter(.val,"CFE")
	. if '$find(val("G",0),":0") set t=$view("probecrit","DEFAULT"),^stop=1
	for i=1:1:$length(t,",") set x=$piece(t,",",i),$extract(x,4)="=",@x
	set PCAT=CAT
	if 0=PCAT,$increment(cnt) write !,"probecrit should find CAT > 0"
	if queslots<CQE,$increment(cnt) write !,CQE," should not be greater than default slots: ",queslots
	do wait^job	; wait for children to terminate
	zshow "G":val
	do in^zshowgfilter(.val,"CAT,CFE,CFS,CFT")
	set t=val("G",0)
	kill ^t
	merge ^t=t
	for i=1:1:$length(t,",") set x=$piece(t,",",i),$extract(x,4)="=",@x,name=$extract(x,1,3) if 0=@name,$increment(cnt) do
	. write !,"Expected non-zero value for ",name," but:"
	. zwrite @name
	if CFE>CFT,$increment(cnt) write !,"CFE should not be more than CFT",! zwrite CFE,CFT
	for name="CFT" set square=$extract(name,1,2)_"S" if @name>@square,$increment(cnt) do
	. write !,name," should be less than ",square,! zwrite @name,@square
	for name="CFT" set pname=$extract(name,1,2)_"N" if @pname>@name,$increment(cnt) do
	. write !,pname," should be less than ",name,! zwrite @pname,@name
	if PCAT<CAT,$increment(cnt) do
	. write !,"the probecrit CAT should be more than that from the process private CAT",! zwrite PCAT,CAT
	set t=$view("gvstats","DEFAULT"),GCAT=+$piece(t,"CAT:",2),t=$view("probecrit","DEFAULT"),PCAT=+$piece(t,"CAT:",2)
	if PCAT-1'=GCAT,$increment(cnt) write !,"last probcrit CAT should be one more than last gvstats CAT",! zwrite PCAT,GCAT
	write !,$select($get(cnt):"FAIL",1:"PASS")," from ",$text(+0)
	quit
activity(gblcnt);
	set act="write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack
	set $ecode="",$etrap="goto err",zl=$zlevel
	for i=1:1 quit:^stop=1  set ^x($job,$justify(i,200))=$j(i,2000) view:'(i#gblcnt) "epoch"
	quit
err	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	set ^stop=1
	zhalt 4	; in case of error within err

