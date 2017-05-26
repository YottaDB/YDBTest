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
gtm7777

case1	; *no* intervening update between DBFLUSH and EPOCH
	do main(0)
	quit

case2	; *yes*, intervening update between DBFLUSH and EPOCH
	do main(1)
	quit

main(intervene)
	set ^x=1
	write $$gcodes("DWT,DFL,DFS,JFS,JRE")
	write !,"#####DBFLUSH",!
	view "DBFLUSH"
	write $$gcodes("DWT,DFL,DFS,JFS,JRE")
	write !,"#####DBSYNC",!
	view "DBSYNC"
	write $$gcodes("DWT,DFL,DFS,JFS,JRE")
	if intervene do
	.	write !,"#####intervene"
	.	zsystem "$gtm_exe/mumps -run %XCMD ""set ^y=1"""
	.	write !
	else  write !
	write "#####EPOCH",!
	view "EPOCH"
	write $$gcodes("DWT,DFL,DFS,JFS,JRE")
	write !,"#####nextupdate",!
	set ^x=2
	write $$gcodes("DWT,DFL,DFS,JFS,JRE")
	quit

expout1	; *no* intervening update between DBFLUSH and EPOCH
	do expout(0)
	quit

expout2	; *yes*, intervening update between DBFLUSH and EPOCH
	do expout(1)
	quit
;
; Print expected output, based on journal state
;
expout(intervene)
	new s,accmeth,jnlstate
	do dump^%DSEWRAP("DEFAULT",.s,"","all")
	set accmeth=s("DEFAULT","Access method")
	if "DISABLED"=s("DEFAULT","Journal State") set jnlstate="nojnl"
	else  if "TRUE"=s("DEFAULT","Journal Before imaging") set jnlstate="jnlbefore"
	else  set jnlstate="jnlnobefore"
	do print(accmeth_jnlstate_intervene)
	quit

print(label)
	new i,done,line
	set done=0
	for i=1:1 quit:done  do
	.	set line=$text(@(label_"+"_i))
	.	set line=$piece(line,";",2)
	.	if $tr(line," ","")="" set done=1 quit
	.	write line,!
	quit

;
; Expected outputs - terminated by empty ';' line
; 0 suffix: no intervene
;

BGnojnl0
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:0,JRE:0
;#####EPOCH
;DWT:1,DFL:1,DFS:1,JFS:0,JRE:0
;#####nextupdate
;DWT:1,DFL:1,DFS:1,JFS:0,JRE:0
;

BGnojnl1
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:0,JRE:0
;#####intervene
;#####EPOCH
;DWT:2,DFL:1,DFS:1,JFS:0,JRE:0
;#####nextupdate
;DWT:2,DFL:1,DFS:1,JFS:0,JRE:0
;

BGjnlbefore0
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:1,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:0
;#####EPOCH
;DWT:1,DFL:1,DFS:1,JFS:1,JRE:1
;#####nextupdate
;DWT:1,DFL:1,DFS:2,JFS:1,JRE:1
;

BGjnlbefore1
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:1,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:0
;#####intervene
;#####EPOCH
;DWT:2,DFL:1,DFS:1,JFS:2,JRE:1
;#####nextupdate
;DWT:2,DFL:1,DFS:2,JFS:2,JRE:1
;

BGjnlnobefore0
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:0,JRE:0
;#####EPOCH
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:1
;#####nextupdate
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:1
;

BGjnlnobefore1
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:1,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:1,DFL:0,DFS:1,JFS:0,JRE:0
;#####intervene
;#####EPOCH
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:1
;#####nextupdate
;DWT:1,DFL:0,DFS:1,JFS:1,JRE:1
;

MMnojnl0
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:0,DFL:0,DFS:1,JFS:0,JRE:0
;#####EPOCH
;DWT:0,DFL:1,DFS:1,JFS:0,JRE:0
;#####nextupdate
;DWT:0,DFL:1,DFS:1,JFS:0,JRE:0
;

MMnojnl1
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:0,DFL:0,DFS:1,JFS:0,JRE:0
;#####intervene
;#####EPOCH
;DWT:0,DFL:1,DFS:1,JFS:0,JRE:0
;#####nextupdate
;DWT:0,DFL:1,DFS:1,JFS:0,JRE:0
;

MMjnlnobefore0
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:0,DFL:0,DFS:1,JFS:0,JRE:0
;#####EPOCH
;DWT:0,DFL:0,DFS:1,JFS:1,JRE:1
;#####nextupdate
;DWT:0,DFL:0,DFS:1,JFS:1,JRE:1
;

MMjnlnobefore1
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBFLUSH
;DWT:0,DFL:0,DFS:0,JFS:0,JRE:0
;#####DBSYNC
;DWT:0,DFL:0,DFS:1,JFS:0,JRE:0
;#####intervene
;#####EPOCH
;DWT:0,DFL:0,DFS:1,JFS:1,JRE:1
;#####nextupdate
;DWT:0,DFL:0,DFS:1,JFS:1,JRE:1
;

;
; Extracts list of codes from process-private ZSHOW "G" output
;
gcodes(codes)
	new i,gstring,zval,res,code
	zshow "G":zval
	do in^zshowgfilter(.zval,codes)
	quit zval("G",0)

