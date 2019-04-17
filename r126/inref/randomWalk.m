;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

randomWalk	;
	; test configs
	set concurrent=10
	set testTimeout=120
	set ^tpNestRate=0.10
	set ^maxDepth=10

	; start concurrent child processes
	set ^isTimeout=0
        for i=1:1:concurrent do
        . set jobstr="job child^randomWalk("_i_"):(output=""child_randomWalk.mjo"_i_""":error=""child_randomWalk.mje"_i_""")"
        . xecute jobstr
        . set job(i)=$zjob
	hang testTimeout
	set ^isTimeout=1
	; wait for child processes to die
        for i=1:1:concurrent set pid=job(i) for  quit:'$zgetjpi(pid,"ISPROCALIVE")  hang 0.001
        quit

child(jobindex) ;
	for  do  quit:^isTimeout
	. do runProc(^tpNestRate)
	quit

runProc(tpNestRate) ;
	write " write ""$TLEVEL is ",$TLEVEL," $TRESTART is ",$TRESTART,""",!",!
	new n,i
	do genGlobalName()
	set odds=80-(100*tpNestRate)
	set action=$random(100)

	if action<20 set @basevar="MySecretValue" write " set ",basevar,"=""MySecretValue""",!
	else  if action<(20+(odds*(1/7))) set x=$get(@basevar) write " set x=$get(",basevar,")",!
	else  if action<(20+(odds*(2/7))) set x=$data(@basevar) write " set x=$data(",basevar,")",!
	else  if action<(20+(odds*(3/7))) do
		. set direction=$random(2)
		. if direction=0 set direction=-1
		. set node=basevar
		. write " set node=$query(",node,",",direction,")",!
		. for  set node=$query(@node,direction) quit:node=""  write " set node=$query(",node,",",direction,")",!
	else  if action<(20+(odds*(4/7))) do
		. set direction=$random(2)
		. if direction=0 set direction=-1
		. set sub=basevar
		. write " set sub=$order(",sub,",",direction,")",!
		. set length=$qlength(sub)
		. if length>0 do
		. . for  set temp=$order(@sub,direction) quit:temp=""  set $piece(sub,",",length)=temp_")" write " set sub=$order(",sub,",",direction,")",!
		. else  do
		. . for  set sub=$order(@sub,direction) quit:sub=""  write " set sub=$order(",sub,",",direction,")",!
	else  if action<(20+(odds*(5/7))) set x=$increment(@basevar,$random(5)) write " set x=$increment(",basevar,",$random(5))",!
	else  if action<(20+(odds*(6/7))) do
		. write " lock ",basevar,!
		. lock @basevar
		. write " lock +",basevar,!
		. lock +@basevar
		. write " lock -",basevar,!
		. lock -@basevar
		. write " lock",!
		. lock
	else  if action<(20+(odds*(7/7))) do
		. set type=$random(2)
		. if type=0 write " kill ",basevar,! kill @basevar
		. else  write " zkill ",basevar,! zkill @basevar
	else  if action<100 do
		. quit:$TLEVEL>^maxDepth
		. write " tstart ():(serial:transaction=""BATCH"")",!
		. tstart ():(serial:transaction="BATCH")
		. set n=$random(20)
		. for i=1:1:n do runProc(tpNestRate/2)
		. tcommit
		. write " tcommit",!
	quit

genGlobalName() ;
	set numSubs=$random(5)
	set baseId=$random(4)

	if baseId=0 set basevar="^MyGlobal1"
	if baseId=1 set basevar="^MyGlobal2"
	if baseId=2 set basevar="MyLocal1xx"
	if baseId=3 set basevar="MyLocal2xx"

	if numSubs>0 set basevar=basevar_"("
	for i=0:1:numSubs-2 set basevar=basevar_$C(34)_"sub"_i_$C(34)_","
	if numSubs>0 set basevar=basevar_$C(34)_"sub"_(numSubs-1)_$C(34)_")"

	quit
