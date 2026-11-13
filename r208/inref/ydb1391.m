;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; A string literal that is a number that is too large, as a Boolean condition or an integer argument
; (see r208/u_inref/literal_bool_int_numoflow-ydb1391.csh)
ydb1391	; A string literal that is a number that is too large issues NUMOFLOW as a condition or an integer argument
	quit
stage1	; The literal as a Boolean condition, compiled at run time (as in Direct Mode)
	new i,line
	for i=1:1 set line=$text(conds+i) quit:line=" quit"  do check($piece(line,";",2,99),"NUMOFLOW")
	quit
conds	; Lines with the literal as a Boolean condition
	;if "1E47" set y=1
	;set:"1E47" y=1
	;set y=$select("1E47":1,1:2)
	;xecute:"1E47" "set y=1"
	;do lbl:"1E47"
	quit
stage2	; The literal as an integer argument of a function, compiled at run time
	new i,line
	for i=1:1 set line=$text(ints+i) quit:line=" quit"  do check($piece(line,";",2,99),"NUMOFLOW")
	quit
ints	; Lines with the literal as an integer argument of a function
	;set y=$extract("abc","1E47")
	;set y=$extract("abc",1,"1E47")
	;set y=$piece("a;b",";","1E47")
	;set y=$justify(1,"1E47")
	quit
stage3	; $ZYCOMPILE() of a line with the literal as a condition and as an integer argument
	new r,line
	for line=" if ""1E47"" set y=1"," set y=$extract(""abc"",""1E47"")" do
	. set r=$zycompile(line)
	. if r["-E-NUMOFLOW" write "PASS : $ZYCOMPILE(",$zwrite(line),") returned NUMOFLOW",!
	. else  write "FAIL : $ZYCOMPILE(",$zwrite(line),") returned [",r,"] instead of NUMOFLOW",!
	quit
stage4	; Controls: literals that are numbers that are not too large, a string that is not a number, conditions
	; that the compiler turns into a literal, the literal in a variable, and $CHAR(), which issued NUMOFLOW for
	; the literal before the fix
	new x
	do check("set y=0 if ""1E46"" set y=1","",1)
	do check("set y=0 if ""abc"" set y=1","",0)
	do check("set y=0 if '0 set y=1","",1)
	do check("set y=0 if 1-1 set y=1","",0)
	do check("set y=$select(""0"":1,""1E46"":2)","",2)
	do check("set y=$select(1:3,""1E47"":4)","",3)
	do check("set y=$extract(""abc"",""2"")","","b")
	do check("set y=$piece(""a;b"","";"",""2E0"")","","b")
	set x="1E47"
	do check("if x set y=1","NUMOFLOW")
	do check("set y=$extract(""abc"",x)","NUMOFLOW")
	do check("set y=$char(""1E47"")","NUMOFLOW")
	quit
gen	; Write the routine of stage 5, with one label per line of conds, ints and $CHAR()
	new f,i,n,line
	set f="xlit.m" open f:newversion use f
	write "xlit",$char(9),"quit",!
	set n=0
	for i=1:1 set line=$text(conds+i) quit:line=" quit"  set n=n+1 write "c",n,$char(9),$piece(line,";",2,99),!,$char(9),"quit",!
	for i=1:1 set line=$text(ints+i) quit:line=" quit"  set n=n+1 write "c",n,$char(9),$piece(line,";",2,99),!,$char(9),"quit",!
	set n=n+1 write "c",n,$char(9),"set y=$char(""1E47"")",!,$char(9),"quit",!
	write "lbl",$char(9),"quit",!
	close f
	write n,!
	quit
stage5	; Run each label of xlit.m (compiled by the caller)
	new i,n
	set n=$zcmdline
	for i=1:1:n do check("do c"_i_"^xlit","NUMOFLOW")
	quit
lbl	quit
check(cmd,experr,expy)	; XECUTE cmd, and check that it issues experr (or no error if experr is ""), and if expy is given,
	; that it sets y to expy
	new err,y
	do try(cmd)
	if experr'=err write "FAIL : ",cmd," : got [",err,"] but expected [",experr,"]",! quit
	if $data(expy),$get(y)'=expy write "FAIL : ",cmd," : set y to [",$get(y),"] but expected [",expy,"]",! quit
	write "PASS : ",cmd," : ",$select(""=err:"no error",1:err),$select($data(expy):", y="_expy,1:""),!
	quit
try(cmd)	; XECUTE cmd, and set err to the mnemonic of the error it issues (if any)
	new $etrap
	set err="",$etrap="set err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	xecute cmd
	quit
