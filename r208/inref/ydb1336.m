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
; Compile JOB commands with job parameter names that start with S (see r208/u_inref/jobparam_s-ydb1336.csh)
;
ydb1336	;
	quit

names	; Each name is followed by whether the name is a valid job parameter name
	new i,name,valid
	for i=1:1 set name=$piece($text(list+i),";",2) quit:""=name  do
	. set valid=$piece($text(list+i),";",3)
	. do try(name,valid)
	quit

try(name,valid)
	new err
	set err=""
	do compile(name)
	if valid,""=err write "PASS : JOB parameter ",name," is accepted",! quit
	if 'valid,err["JOBPARUNK" write "PASS : JOB parameter ",name," is rejected with JOBPARUNK",! quit
	write "FAIL : JOB parameter ",name," gave error [",err,"] but ",$select(valid:"no error",1:"JOBPARUNK")," was expected",!
	quit

compile(name)	; Sets err to the mnemonic of the error that compiling a JOB command with job parameter name gives, if any
	new $etrap
	set $etrap="set err=$piece($zstatus,"","",3),$ecode="""" quit"
	; XECUTE compiles the JOB command, and "if 0" makes sure the JOB command does not run
	xecute "if 0  job ^nosuchrtn:("_name_")"
	quit

list	;
	;S;0
	;SA;0
	;SZ;0
	;SYS;0
	;STAR;0
	;SWAPPINGS;0
	;STA="/bin/true";1
	;STARTUP="/bin/true";1
	;SCH="x";1
	;SCHEDULE="x";1
	;SWA;1
	;SWAPPING;1
	;
