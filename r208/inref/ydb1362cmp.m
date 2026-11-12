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
; Comparisons with a string literal that is a number that is too large (see r208/u_inref/literal_cmp_numoflow-ydb1362.csh)
ydb1362cmp	; A comparison with < or > of a number and a string literal that is a number that is too large issues NUMOFLOW
	quit
stage1	; Each comparison, compiled at run time (as in Direct Mode)
	new c
	for c="1<""1E47""","1>""1E47""","""1E47""<1","1'<""1E47""","1'>""1E47""" do check("write "_c_",!","NUMOFLOW")
	quit
stage2	; The comparison in a Boolean expression
	do check("write 1&(1<""1E47""),!","NUMOFLOW")
	quit
stage3	; $ZYCOMPILE() of a line with the comparison
	new r
	set r=$zycompile(" write 1<""1E47""")
	if r["%YDB-E-NUMOFLOW" write "PASS : $ZYCOMPILE() returned NUMOFLOW",!
	else  write "FAIL : $ZYCOMPILE() returned [",r,"] instead of NUMOFLOW",!
	quit
stage4	; Controls: a string literal that is a number that is not too large, and a string in a variable
	new x
	do check("write 1<""1E46"",!","")
	do check("write ""1E46"">1,!","")
	do check("write 1'>""1E46"",!","")
	do check("write 1'<""1E46"",!","")
	set x="1E47"
	do check("write 1<x,!","NUMOFLOW")
	quit
gen	; Write the routines of stages 5 and 6
	new f
	set f="xcmp.m" open f:newversion use f write "xcmp",$char(9),"write 1<""1E47"",!",!,$char(9),"write ""line 2"",!",!,$char(9),"quit",! close f
	set f="xcmpx.m" open f:newversion use f write "xcmpx",$char(9),"xecute ""write 1<""""1E47"""",!""",!,$char(9),"write ""line 2"",!",!,$char(9),"quit",! close f
	quit
check(cmd,experr)	; XECUTE cmd, and check that it issues experr (or no error if experr is "")
	new err,out
	do try(cmd)
	if experr=err write "PASS : ",cmd," : ",$select(""=err:"no error",1:err),!
	else  write "FAIL : ",cmd," : got [",err,"] but expected [",experr,"]",!
	quit
try(cmd)	; XECUTE cmd, and set err to the mnemonic of the error it issues (if any)
	new $etrap
	set err="",$etrap="set err=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" quit"
	xecute cmd
	quit
