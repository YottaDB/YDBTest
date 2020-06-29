;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ydb596	;
	new ret,cmd,xstr,delim,trigstr
	for cmd="KILL","ZKILL","ZTRIGGER" do
	. set ^gbl="cmd"
	. write "# Test no error when ",cmd," trigger (no SET trigger) specifies -DELIM or -ZDELIM",!
	. set delim=$select($random(2):"-zdelim",1:"-delim")
	. write "# Add "_cmd_" trigger",!
	. set trigstr="+^gbl -commands="_cmd_" "_delim_"=""|"" -xecute=""do trig^ydb596"" -name=trig1"
	. write "# Loading trigger : [",trigstr,"]",!
	. set ret=$ZTRIGGER("ITEM",trigstr) ; add trigger
	. set xstr=cmd_" ^gbl"
	. write "# Verify $ZTDELIM reflects value of ""|"" inside trigger",!
	. xecute xstr
	. write "# Deleting trigger : [",trigstr,"]",!
	. set ret=$ZTRIGGER("ITEM","-trig1")	; delete trigger
	. write !
	. ;
	. write "# Test error when -PIECES is specified and only "_cmd_" type trigger is specified.",!
	. set trigstr=trigstr_" -pieces=1"
	. write "# Loading trigger : [",trigstr,"]",!
	. set ret=$ZTRIGGER("ITEM",trigstr) ; add trigger
	. write !

	for cmd="SET","KILL","ZKILL","ZTRIGGER" do
	. write "# Test $ZTDELIM is NULL inside ",cmd," trigger if -DELIM or -ZDELIM was not specified.",!
	. set ^gbl="cmd"
	. set trigstr="+^gbl -commands="_cmd_" -xecute=""do trig^ydb596"" -name=trig1"
	. write "# Loading trigger : [",trigstr,"]",!
	. set ret=$ZTRIGGER("ITEM",trigstr) ; add trigger
	. set xstr=cmd_" ^gbl"_$select("SET"=cmd:"=1",1:"")
	. write "# Verify $ZTDELIM reflects value of """" inside trigger",!
	. xecute xstr
	. write "# Deleting trigger : [",trigstr,"]",!
	. set ret=$ZTRIGGER("ITEM","-trig1")	; delete trigger
	. write !
	quit

trig	;
	zwrite $ZTDELIM
	quit

