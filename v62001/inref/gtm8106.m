;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2014-2015 Fidelity National Information 	;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8106	;Verify VIEW "GVSRESET"; also VIEW accepts lower-case regions and * as all regions
	;
	new (act,debug)
	if '$data(act) new act set act="use $principal write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	do Init^GTMDefinedTypesInit					; set up version-specific view of the file header
	if $data(gtmtypfldindx) do					; if it doesn't have a cross-index
	. set item="0"							; cross reference it to be useful
	. for  set item=$order(gtmtypes("sgmnt_data",item)) quit:+item'=item  do
	. . set gtmtypfldindx("sgmnt_data",$piece(gtmtypes("sgmnt_data",item,"name"),".",2))=item
	set dev="dse"				; activate DSE through a PIPE device
	open dev:(command="dse":exception="goto badopen")::"PIPE"
	use dev
	for i=1:1:30 read resp:1 quit:'$test				; clear initial DSE output
	use $principal
	write:$get(debug) !,"initial dump of locations",!		;locations at the begining, middle and end of target area
	for name="encryption_hash","gvstats_rec","intrpt_recov_resync_strm_seqno" do
	. set item=gtmtypfldindx("sgmnt_data",name)
	. set offset=gtmtypes("sgmnt_data",item,"off"),length=gtmtypes("sgmnt_data",item,"len")
	. set mname=$$mname(name)
	. set @mname=offset+$select("intrpt_recov_resync_strm_seqno"=name:0,1:length)
	. quit:'$get(debug)
	. set dummy=$$dsedecloc(@mname-4,dev),dummy=$$dsedecloc(@mname,dev)
	kill gtmtypes,gtmstructs,gtmunions,gtmtypfldindx			; to avoid overwhelming ZWRITE output
	write:$get(debug) !,"marking boundaries and interior locations",!
	for name="encryption_hash","gvstats_rec","intrpt_recov_resync_strm_seqno" do
	. set mname=$$mname(name)
	. set vals(@mname-4)=$$dsedecloc(@mname-4,dev,"DEAD"),vals(@mname)=$$dsedecloc(@mname,dev,"DEAD")
	write:$get(debug) !,"showing marked locations",!
	if $get(debug) for name="encryption_hash","gvstats_rec","intrpt_recov_resync_strm_seqno" do
	. set mname=$$mname(name)
	. set dummy=$$dsedecloc(@mname-4,dev),dummy=$$dsedecloc(@mname,dev)
	write:$get(debug) !,"clearing stats",!
	use dev
	write "change -fileheader -gvstatsreset",!			; the command we're actually testing
	set y=""
	for i=1:1:30 read x:1 set y=y_x quit:"DSE> "=y!'$test		; use scratch variable so resp shows up on error reports
	use $principal
	zwrite:$get(debug) vals
	write:$get(debug) !,"showing result of the clearing",!
	set outcome=""
	for name="encryption_hash","gvstats_rec","intrpt_recov_resync_strm_seqno" do
	. set mname=$$mname(name)
	. set outcome=outcome_$$dsedecloc(@mname-4,dev)_$$dsedecloc(@mname,dev)
	write:$get(debug) outcome,!					; markers should remain just before & just after target area
	if "0000DEAD0000DEAD0000000000000000000000000000DEAD"'=outcome,$increment(cnt) xecute act
	write:$get(debug) !,"fixing boundary locations",!		; fix the locations outside the target area we cleared
	set mname=$$mname("encryption_hash")
	set dummy=$$dsedecloc(@mname-4,dev,vals(@mname-4))
	set mname=$$mname("intrpt_recov_resync_strm_seqno")
	set dummy=$$dsedecloc(@mname,dev,vals(@mname))
	write:$get(debug) !,"showing final state",!
	if $get(debug) for name="encryption_hash","gvstats_rec","intrpt_recov_resync_strm_seqno" do
	. set mname=$$mname(name)
	. set dummy=$$dsedecloc(@mname-4,dev),dummy=$$dsedecloc(@mname,dev)
	close dev
	for region="default","","*" do
	. kill ^a for i=1:1:10000 set ^a(i)=i					; generate some activity
	. set gvstats=$view("gvstats","default")
	. if +$piece(gvstats,"SET:",2)'=10000,$increment(cnt) xecute act
	. zshow "g":gvstats						; should see both database and process-private
	. if +$piece(gvstats("G",0),"SET:",2)'=10000,$increment(cnt) xecute act
	. if $length(region) view "gvsreset":region				; do region specific or wildcard reset
	. else  view "gvsreset"							; do default (all region) reset
	. set gvstats=$view("gvstats","default")
	. if +$piece(gvstats,"SET:",2)'=0,$increment(cnt) xecute act		; check that reset worked
	. zshow "g":gvstats
	. if +$piece(gvstats("G",0),"SET:",2)'=0,$increment(cnt) xecute act	; check that process private reset worked too
	write $select('$get(cnt):"PASS",1:"FAIL")," from ",$text(+0)
	quit
badopen	xecute act
	quit
dsedecloc(arg,dev,value)						; execute change -fileheader -declocaton=arg[ -value=value]
	new old,x,y
	set:"NONE"'=$get(value,"NONE") arg=arg_" -value="_value
	set (resp,y)=""
	use dev
	write "change -fileheader -declocation="_arg,!
	for i=1:1:30 read x:1 set resp=resp_x if resp["Size = ","]"=$extract(resp,$length(resp)) do  quit
	. use:$get(debug) $principal write resp,!				; convert response from DSE
	. set old=$$FUNC^%DH($piece($piece(resp," = ",2)," "))
	use dev
	for i=1:1:30 read x:1 set y=y_x quit:"DSE> "=y!'$test		; use scratch variable so resp shows up on error reports
	use $principal
	quit $get(old,"0xFFFFFFFF")	; return the "old" value or "0xFFFFFFFF" if all reads timedout in case the invoker cares
	;
err	if $estack write:'$stack !,"error handling failed",!,$zstatus zgoto @($zlevel-1_":"_$zposition)
	for lev=$stack:-1:0 set loc=$stack(lev,"PLACE") quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
	;
mname(mname)							; turn C field name into an M style name
	set mname="_"_mname,i=2
	for  set $extract(mname,i-1,i)=$char($ascii(mname,i)-32),i=$find(mname,"_") quit:'i
	quit mname
readonly
	new (act)
	if '$data(act) new act set act="use $principal write !,$zpos,! zprint @$zpos zshow ""v"""
	new $etrap,$estack; zbreak err:"zstep into"
	set $ecode="",$etrap="goto err",zl=$zlevel;,$zstep="zprint @$zpositio zstep into"
	for i=1:1:100 set x=$order(^a(1))
	zshow "g":b
	if 100'=+$piece(b("G",0),"ORD:",2),$increment(cnt) xecute act
	view "resetgvstats"
	zshow "g":a
	if 0'=+$piece(a("G",0),"ORD:",2),$increment(cnt) xecute act
	write $select('$get(cnt):"PASS",1:"FAIL")," from readonly^",$text(+0)
	quit
