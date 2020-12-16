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

ydb664	;
	set hyphenstr="--------------------------------------------------------------------------------------------------"
	;
	write !,"# Test that $VIEW(""ZTRIGGER_OUTPUT"") return 1 by default",!,hyphenstr,!
	set xstr="WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	write xstr,!  xecute xstr
	;
	write !,"# Test that VIEW ""ZTRIGGER_OUTPUT"":0 causes $VIEW(""ZTRIGGER_OUTPUT"") to return 0",!,hyphenstr,!
	set xstr="VIEW ""ZTRIGGER_OUTPUT"":0  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	write xstr,!  xecute xstr
	;
	write !,"# Test that VIEW ""ZTRIGGER_OUTPUT"" causes $VIEW(""ZTRIGGER_OUTPUT"") to return 1",!,hyphenstr,!
	set xstr="VIEW ""ZTRIGGER_OUTPUT""  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	write xstr,!  xecute xstr
	;
	write !,"# Test that VIEW ""ZTRIGGER_OUTPUT"":1 causes $VIEW(""ZTRIGGER_OUTPUT"") to return 1",!,hyphenstr,!
	write "# Since ZTRIGGER_OUTPUT setting is currently 1, reset it to 0 before testing it gets set to 1",!
	set xstr="VIEW ""ZTRIGGER_OUTPUT"":0  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	write xstr,!  xecute xstr
	set xstr="VIEW ""ZTRIGGER_OUTPUT"":1  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	write xstr,!  xecute xstr
	;
	set setting(0)="disables",setting(1)="enables",^cntr=1
	for setting=0,1 do
	. write "# Test that VIEW ""ZTRIGGER_OUTPUT"":"_setting_" "_setting(setting)_" output from $ZTRIGGER() if outside TSTART/TCOMMIT",!,hyphenstr,!
	. set xstr="VIEW ""ZTRIGGER_OUTPUT"":"_setting_"  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	. write xstr,!  xecute xstr
	. set varname="myname"_^cntr
	. set trigstr="set x=$ZTRIGGER(""ITEM"",""+^"_varname_" -commands=S -xecute=""""write $increment(^cntr),!"""" -name="_varname_""")"
	. write trigstr,! xecute trigstr
	. write "# Verify trigger actually got installed by doing a SET that will invoke the trigger",!
	. set xstr="set ^"_varname_"=1"
	. write xstr,!  xecute xstr
	. ;
	. write "# Test that VIEW ""ZTRIGGER_OUTPUT"":"_setting_" "_setting(setting)_" output from $ZTRIGGER() if inside TSTART/TCOMMIT",!,hyphenstr,!
	. set xstr="VIEW ""ZTRIGGER_OUTPUT"":"_setting_"  WRITE $VIEW(""ZTRIGGER_OUTPUT""),!"
	. write xstr,!  xecute xstr
	. set varname="myname"_^cntr
	. tstart ():serial
	. set trigstr="set x=$ZTRIGGER(""ITEM"",""+^"_varname_" -commands=S -xecute=""""write $increment(^cntr),!"""" -name="_varname_""")"
	. write trigstr,! xecute trigstr
	. tcommit
	. write "# Verify trigger actually got installed by doing a SET that will invoke the trigger",!
	. set xstr="set ^"_varname_"=1"
	. write xstr,!  xecute xstr
	;
	quit
