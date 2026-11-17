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
ydb1400	; Helper routines for the r208/zintr_dmode_error-ydb1400 subtest
	quit
	;
drive	; Run child^ydb1400 for the stage in $ZCMDLINE, with a PIPE device as the principal device of the child, so that
	; direct mode in the child reads commands from a device that is not a terminal. Wait for the direct mode prompt
	; of the child, interrupt the child (stage 4 instead waits for the $ZTIMEOUT of the child), and write each line
	; of the output of the child. In stage 5 the child returns to the prompt, where the child is sent two commands.
	new child,i,line,n,out,pid,prompt,prompts,sent,stage
	set stage=$zcmdline
	set prompt=$ztrnlnm("gtm_prompt")
	if ""=prompt write "FAIL : the gtm_prompt environment variable is not set",!  quit
	set child="child"
	; The commands name /bin/sh, as "2>&1" means something else to tcsh, which is the default shell of a PIPE device here
	open child:(shell="/bin/sh":command="$gtm_dist/mumps -run child^ydb1400 "_stage_" 2>&1")::"pipe"
	use child
	read pid:60
	; No newline follows the prompt, so a READ of the prompt ends only when the READ times out. If the child writes
	; more by then, the prompt is at the start of that line. Either way the prompt is noted and taken off the line.
	set (n,prompts,sent)=0
	for i=1:1:300 read line:1 quit:$zeof  do
	. for  quit:line'[prompt  set prompts=prompts+1,line=$piece(line,prompt,1)_$piece(line,prompt,2,999)
	. set:""'=line n=n+1,out(n)=line
	. if (1=prompts)&'sent&(4'=stage) set sent=1 do intrpt(pid) use child
	. if (2=prompts)&(1=sent) set sent=2 write "write ""typed command ran"",!",!,"halt",!
	close child
	use $principal
	for i=1:1:n write "child : ",out(i),!
	quit
	;
intrpt(pid)	; Send a MUPIP INTRPT to pid. The output of the command names the pid, so that output is read and not written.
	new line,mupip
	set mupip="mupip"
	open mupip:(shell="/bin/sh":command="$gtm_dist/mupip intrpt "_pid_" 2>&1":readonly)::"pipe"
	use mupip
	for  read line:60 quit:$zeof!'$test
	close mupip
	quit
	;
child	; $ZCMDLINE is the stage
	new stage
	set stage=$zcmdline
	write $job,!
	set $ztrap="write ""$ZTRAP code ran, error is "",$piece($piece($zstatus,"","",3),""-"",3),! halt"
	if 2=stage set $ztrap="",$etrap="write ""$ETRAP code ran, error is "",$piece($piece($zstatus,"","",3),""-"",3),! halt"
	if (1=stage)!(2=stage) set $zinterrupt="do err^ydb1400"
	if 3=stage set $zinterrupt="zgoto 1:after^ydb1400"
	if 4=stage set $ztimeout="2:do err^ydb1400"
	if 5=stage set $zinterrupt="write 1/0"
	break
	write "the child returned from the BREAK",!
	quit
	;
err	;
	write "in err^ydb1400",!
	write 1/0
	quit
	;
after	;
	write "at after^ydb1400",!
	write 1/0
	quit
