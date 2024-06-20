;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.
; All rights reserved.
;
;	This source code contains the intellectual property
;	of its copyright holder(s), and is made available
;	under a license.  If you do not know the terms of
;	the license, please stop and do not read further.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Make sure that ydb stats count the number of triggers invoked
; for each type of trigger: SET, KILL, and ZTRIGGER

test
	view "statshare"  ;share stats so YGBLSTAT works
	set expected="STG,KTG,ZTG"
	set tmp=$ztrigger("item","+^a -command=set,kill,zkill,ztrigger -xecute=""set x=1"" -name=atrig")
	;
	;Perform trigger events to create the stats
	set ^a=1
	zkill ^a
	set ^a=2
	kill ^a
	set ^a=3
	ztrigger ^a
	;
	write !,"Raw stats:",!
	zshow "G":ZSHOWstats
	zwrite ZSHOWstats("G",0)
	set YGBLSTATs=$$STAT^%YGBLSTAT($j,"STG,KTG,ZTG")
	write "YGBLSTATs="_YGBLSTATs,!
	;
	write !,"Extracted ZSHOW stats:",!
	for i=1:1:3 set stat=$piece(expected,",",i) write stat,":",$$filter(ZSHOWstats("G",0),stat),!
	write "Ordered YGBLSTAT stats:",!
	for i=1:1:3 set stat=$piece(expected,",",i) write stat,":",$$filter(YGBLSTATs,stat),!
	quit

filter(stats,stat)  ; extract value stats[stat]
	new i,item,id,value
	set value=""
	for i=1:1:$l(stats,",") do  quit:value'=""
	.set item=$piece(stats,",",i),id=$piece(item,":")
	.if id=stat set value=$piece(item,":",2) quit
	quit value
