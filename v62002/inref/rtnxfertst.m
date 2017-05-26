;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; Test possible external call/goto scenarios. Test both with alphabetic routines/labels and % prefixed routines/labels.
; Primary purpose of this test was to test all types of calls/gotos for major compiler changes with a form that allowed
; isolation of a given test that perhaps fails. This was used (heavily) in the opcode reduction project for autorelink
; enabled platforms where the parameter types passed to glue code (assembler) routines changed from pointers to indexes.
;
	set $etrap="write $zstatus,!! zwrite  zhalt 1"
	set testlist="donoargs doindrnoargs1 doindrnoargs2 doindrnoargs3 doindrnoargs4 doindrnoargs5"
	set testlist=testlist_" dowargs doindrwargs2 doindrwargs4 doindrwargs5"
	set testlist=testlist_" funcnoargs funcindrnoargs1 funcindrnoargs2 funcindrnoargs3 funcindrnoargs5"
	set testlist=testlist_" funcwargs funcindrwargs2 funcindrwargs5"
	set testlist=testlist_" goto zgoto tstlblmiss tstindrlblmiss nolblcall"
	for tidx=1:1:$zlength(testlist," ") do
	. set test=$zpiece(testlist," ",tidx)
	. write !!,"Test ",tidx,": ",test,!!
	. do @test
	write !!,"Tests complete",!
	quit

;
; Test DO without args (no indirects)
;
donoargs
	new
	do donoargs^targrtn
	do donoargs^targrtn
	; % versions
	do %donoargs^%targrtn
	do %donoargs^%targrtn
	quit

;
; Test indirect DO without args - each of routine and label are indirects
;
doindrnoargs1
	new
	set a="donoargs"
	set b="targrtn"
	do @a^@b
	do @a^@b
	; % versions
	set a="%donoargs"
	set b="%targrtn"
	do @a^@b
	do @a^@b
	quit

;
; Test indirect DO without args - only the label is indirect
;
doindrnoargs2
	new
	set a="donoargs"
	do @a^targrtn
	do @a^targrtn
	; %version
	set a="%donoargs"
	do @a^%targrtn
	do @a^%targrtn
	quit

;
; Test indirect DO without args - only the routine is indirect
;
doindrnoargs3
	new
	set b="targrtn"
	do donoargs^@b
	do donoargs^@b
	; % versions
	set b="%targrtn"
	do %donoargs^@b
	do %donoargs^@b
	quit

;
; Test indirect DO without args - entire entryref is one indirect
;
doindrnoargs4
	new
	set a="donoargs^targrtn"
	do @a
	do @a
	; % versions
	set a="%donoargs^%targrtn"
	do @a
	do @a
	quit

;
; Test indirect DO without args - XECUTEd do statement
;
doindrnoargs5
	new
	set a="do donoargs^targrtn"
	xecute a
	xecute a
	; % versions
	set a="do %donoargs^%targrtn"
	xecute a
	xecute a
	quit

;
; Test DO with args (no indirects)
;
dowargs
	new
	set arg3=3,arg7=7
	set arg4="arg4",arg8="arg8"
	set arg9=9,arg10="arg10"
	do dowargs^targrtn("arg1",2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	set arg3=3.3,arg7=7.7
	set arg4="arg4.4",arg8="arg8.8"
	do dowargs^targrtn("arg1.1",2.2,arg3,.arg4,"arg5",6.6,.arg7,arg8,arg9,.arg10)
	; % versions
	set arg3=3,arg7=7
	set arg4="arg4",arg8="arg8"
	do %dowargs^%targrtn("arg1",2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	set arg3=3.3,arg7=7.7
	set arg4="arg4.4",arg8="arg8.8"
	do %dowargs^%targrtn("arg1.1",2.2,arg3,.arg4,"arg5",6.6,.arg7,arg8,arg9,.arg10)
	quit

;
; Test indirect DO with args - only label is indirect
;
doindrwargs2
	new
	set a="dowargs"
	do @a^targrtn(1,2,3,4,5,6,7,8,9,10)
	do @a^targrtn(1,2,3,4,5,6,7,8,9,10)
	; % versions
	set a="%dowargs"
	do @a^%targrtn(1,2,3,4,5,6,7,8,9,10)
	do @a^%targrtn(1,2,3,4,5,6,7,8,9,10)
	quit

;
; Test indirect DO with args - entire entryref is one indirect
;
doindrwargs4
	new
	set a="dowargs^targrtn"
	do @a@(1,2,3,4,5,6,7,8,9,10)
	do @a@(1,2,3,4,5,6,7,8,9,10)
	; % versions
	set a="%dowargs^%targrtn"
	do @a@(1,2,3,4,5,6,7,8,9,10)
	do @a@(1,2,3,4,5,6,7,8,9,10)
	quit

;
; Test indirect DO with args - call is XECUTEd
;
doindrwargs5
	new
	set a="do dowargs^targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute a
	xecute a
	; % versions
	set a="do %dowargs^%targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute a
	xecute a
	quit

;
; Test function call ($$) without args (no indirects)
;
funcnoargs
	new
	set x=$$funcnoargs^targrtn
	write "return from invocation 1: ",x,!
	set y=$$funcnoargs^targrtn
	write "return from invocation 2: ",y,!
	; % versions
	set x=$$%funcnoargs^%targrtn
	write "return from invocation 1: ",x,!
	set y=$$%funcnoargs^%targrtn
	write "return from invocation 2: ",y,!
	quit

;
; Test indirect function call ($$) without args - each of routine and label are indirects
;
funcindrnoargs1
	new
	set a="funcnoargs"
	set b="targrtn"
	set x=$$@a^@b
	write "return from invocation 1: ",x,!
	set y=$$@a^@b
	write "return from invocation 2: ",y,!
	; % versions
	set a="%funcnoargs"
	set b="%targrtn"
	set x=$$@a^@b
	write "return from invocation 1: ",x,!
	set y=$$@a^@b
	write "return from invocation 2: ",y,!
	quit

;
; Test indirect function call ($$) without args - only the label is indirect
;
funcindrnoargs2
	new
	set a="funcnoargs"
	set x=$$@a^targrtn
	write "return from invocation 1: ",x,!
	set y=$$@a^targrtn
	write "return from invocation 2: ",y,!
	; % versions
	set a="%funcnoargs"
	set x=$$@a^%targrtn
	write "return from invocation 1: ",x,!
	set y=$$@a^%targrtn
	write "return from invocation 2: ",y,!
 	quit

;
; Test indirect function call ($$) without args - only the routine is indirect
;
funcindrnoargs3
	new
        set b="targrtn"
	set x=$$funcnoargs^@b
	write "return from invocation 1: ",x,!
	set y=$$funcnoargs^@b
	write "return from invocation 2: ",y,!
	; % versions
        set b="%targrtn"
	set x=$$%funcnoargs^@b
	write "return from invocation 1: ",x,!
	set y=$$%funcnoargs^@b
	write "return from invocation 2: ",y,!
 	quit

;
; Test indirect function call ($$) without args - XECUTEd function call
;
funcindrnoargs5
	new
	set a="set x=$$funcnoargs^targrtn"
	xecute a
	write "return from invocation 1: ",x,!
	set b="set y=$$funcnoargs^targrtn"
	xecute b
	write "return from invocation 2: ",y,!
	; % versions
	set a="set x=$$%funcnoargs^%targrtn"
	xecute a
	write "return from invocation 1: ",x,!
	set b="set y=$$%funcnoargs^%targrtn"
	xecute b
	write "return from invocation 2: ",y,!
	quit

;
; Test function call ($$) with args (no indirects)
;
funcwargs
	new
	set arg3=3,arg7=7
	set arg4="arg4",arg8="arg8"
	set arg9=9,arg10="arg10"
	set x=$$funcwargs^targrtn("arg1",2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	write "return value from 1st invocation: ",x,!!
	set arg3=3.3,arg7=7.7
	set arg4="arg4.4",arg8="arg8.8"
	set y=$$funcwargs^targrtn("arg1.1",2.2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	write "return value from 2nd invocation: ",y,!!
	; % versions
	set arg3=3,arg7=7
	set arg4="arg4",arg8="arg8"
	set x=$$%funcwargs^%targrtn("arg1",2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	write "return value from 1st invocation: ",x,!!
	set arg3=3.3,arg7=7.7
	set arg4="arg4.4",arg8="arg8.8"
	set y=$$%funcwargs^%targrtn("arg1.1",2.2,arg3,.arg4,"arg5",6,.arg7,arg8,arg9,.arg10)
	write "return value from 2nd invocation: ",y,!!
	quit

;
; Test indirect function call ($$) with args - only label is indirect
;
funcindrwargs2
	new
	set a="funcwargs"
	set x=$$@a^targrtn(1,2,3,4,5,6,7,8,9,10)
	write "return from invocation 1: ",x,!
	set y=$$@a^targrtn(1,2,3,4,5,6,7,8,9,10)
	write "return from invocation 2: ",y,!
	; % versions
	set a="%funcwargs"
	set x=$$@a^%targrtn(1,2,3,4,5,6,7,8,9,10)
	write "return from invocation 1: ",x,!
	set y=$$@a^%targrtn(1,2,3,4,5,6,7,8,9,10)
	write "return from invocation 2: ",y,!
 	quit

;
; Test indirect function call ($$) with args - XECUTE function call
;
funcindrwargs5
	new
	set a="set x=$$funcwargs^targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute a
	write "return from invocation 1: ",x,!
	set b="set y=$$funcwargs^targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute b
	write "return from invocation 2: ",y,!
	; % versions
	set a="set x=$$%funcwargs^%targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute a
	write "return from invocation 1: ",x,!
	set b="set y=$$%funcwargs^%targrtn(1,2,3,4,5,6,7,8,9,10)"
	xecute b
	write "return from invocation 2: ",y,!
	quit

;
; Test GOTO type transfers
;
goto
	new
	;
	; Generate 2 routines to goto each other to make sure we end up correctly
	;
	set TAB=$char(9)
	set maxgen=100
	set maxgen=100\2*2	; Make sure even number
	set file="goto1.m"
	open file:new
	use file
	for i=1:2:maxgen do
	. write !,"lbl",i,TAB,"set cnt=$incr(cnt)",!
	. write TAB,"goto lbl",i+1,"^goto2",!
	write !,"lbl",maxgen+1,TAB,"quit",!
	close file
	set file="goto2.m"
	open file:new
	use file
	for i=2:2:maxgen do
	. write !,"lbl",i,TAB,"set cnt=$incr(cnt)",!
	. write TAB,"goto lbl",i+1,"^goto1",!
	close file
	;
	; Drive generated routines
	;
	do ^goto1
	if (cnt'=maxgen) do
	. write !,"Count = ",cnt," but expected ",maxgen," -- FAIL",!
	. zshow "*"
	. zhalt 1
	write !,"goto - PASS",!
	open "goto1.m"
	close "goto1.m":delete
	open "goto2.m"
	close "goto2.m":delete
	zsystem "rm goto*.o"
	quit

;
; Test ZGOTO type transfers
;
zgoto
	new
	;
	; Generate 2 routines to goto each other to make sure we end up correctly
	;
	set TAB=$char(9)
	set maxgen=100
	set maxgen=100\2*2	; Make sure even number
	set file="zgoto1.m"
	open file:new
	use file
	for i=1:2:maxgen do
	. write !,"lbl",i,TAB,"set cnt=$incr(cnt)",!
	. write TAB,"zgoto $zlevel:lbl",i+1,"^zgoto2",!
	write !,"lbl",maxgen+1,TAB,"quit",!
	close file
	set file="zgoto2.m"
	open file:new
	use file
	for i=2:2:maxgen do
	. write !,"lbl",i,TAB,"set cnt=$incr(cnt)",!
	. write TAB,"zgoto $zlevel:lbl",i+1,"^zgoto1",!
	close file
	;
	; Drive generated routines
	;
	do ^zgoto1
	if (cnt'=maxgen) do
	. write !,"Count = ",cnt," but expected ",maxgen," -- FAIL",!
	. zshow "*"
	. zhalt 1
	write !,"zgoto - PASS",!
	open "zgoto1.m"
	close "zgoto1.m":delete
	open "zgoto2.m"
	close "zgoto2.m":delete
	zsystem "rm zgoto*.o"
	quit

;
; Test LABELMISSING error as raised by glue code - requires replaced routine.
;
tstlblmiss
	new
	new $etrap
	set $etrap="do goterror^"_$text(+0)
	set rtn="tstlblmiss"
	set TAB=$char(9)
	do creatertn("lblmiss1.m","label1")
	zsystem "cp lblmiss1.m lblmiss.m"
	zlink "lblmiss.m"
	do label1^lblmiss		; Drive 1st version of routine
	do creatertn("lblmiss2.m","label2")
	zsystem "cp lblmiss2.m lblmiss.m"
	zlink "lblmiss.m"
	do label2^lblmiss		; Drive 2nd version but with new label (should work)
	do label1^lblmiss		; Drive 2nd version of routine - should cause error
	write "Should not be here ("_$zposition_")- should have driven an error - FAIL",!
	quit
;
; Test LABELMISSING error as raised by glue code when call is by indirect - requires replaced routine
;
tstindrlblmiss
	new
	new $etrap
	set $etrap="do goterror^"_$text(+0)
	set rtn="tstindrlblmiss"
	set TAB=$char(9)
	do creatertn("lblmiss1.m","label1")
	zsystem "cp lblmiss1.m lblmiss.m"
	zlink "lblmiss.m"
	do @("label1^lblmiss")		; Drive 1st version of routine
	do creatertn("lblmiss2.m","label2")
	zsystem "cp lblmiss2.m lblmiss.m"
	zlink "lblmiss.m"
	do @("label2^lblmiss")		; Drive 2nd version but with new label (should work)
	do @("label1^lblmiss")		; Drive 2nd version of routine - should cause error
	write "Should not be here ("_$zposition_")- should have driven an error - FAIL",!
	quit
;
; Entered when get an error - hopefully the one we expect (part of tst*lblmiss)
;
goterror
	set error=$zpiece($zstatus,",",3)
	if (("%GTM-E-LABELMISSING"'=error)!("label1"'=$zpiece($zstatus,": ",2))) do
	. zshow "*"
	. zhalt 1
	;
	; We got the error we wanted - clean up and exit
	;
	open "lblmiss.m"
	close "lblmiss.m":delete
	open "lblmiss1.m"
	close "lblmiss1.m":delete
	open "lblmiss2.m"
	close "lblmiss2.m":delete
	zsystem "rm lblmiss*.o"
	write "Test ",rtn," PASS",!
	set $ecode=""
	quit
;
; Routine to create a simple test file (part of tst*lblmiss)
;
creatertn(rtn,lbl)
	open rtn:new
	use rtn
	write TAB,"write ""Invalid invocation of "",$text(+0),"" routine - enter at label"",!",!
	write TAB,"zhalt 1",!
	write lbl,TAB,"write ""Arrived at entryref ",lbl,"^",$zpiece(rtn,".",1),""",!",!
	write TAB,"quit",!
	close rtn
	quit

;
; Test to call a routine with args without a label though the called routine does have a label. This
; should work if the label appears before any code in the routine.
;
nolblcall
	new
	do ^targrtn(1,42)
	do ^%targrtn(1,42)
	quit
