;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2012, 2014 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm6571	; Evil program to produce MUTEXLCKALERT to test procstuckexec
	new (act)
	if '$data(act) new act set act="use $principal write !,$zposition,! zprint @$zposition zshow ""*"""
	new $etrap
	set $ecode="",$etrap="goto err",zl=$zl
	set time=150,jobCount=4
	write "Parent pid is "_$job,!
	view "jobpid":1
	set pipesh="p1"
	; Start a process to wait for 3 procstuckexec invocations, giving 90 seconds each.
	open pipesh:(shell="/usr/local/bin/tcsh":command="./gtm6571_watch.csh | tee watch.log")::"pipe"
	tstart ():serial
	set ^a=$trestart
	if 3>$trestart trestart					; Get us to the 4-th retry
	for i=1:1:jobCount do
	. job silly^gtm6571::30					; Cannot use ^job infrastructure as it would go TPNOTACID on us
	. set jobs(i)=$zjob
	use pipesh
	for i=time/30:-1:0 read line:30 quit:$test!$zeof 	; Read timeout cannot be extended without running into TPNOTACID
	set good=line["procstuckexec ran"
	trollback
	use $principal
	write line,!,$select(good:"PASS",1:"FAIL")," from ",$text(+0),!
	for i=1:1:jobCount do
	. for j=1:1:30 set success=$zsigproc(jobs(i),0) quit:(success)  hang 1
	. if ('success) write "JOB "_jobs(i)_" did not die in 30 seconds",!
	quit
silly
	set file="silly"_$job_".txt"
	open file:newversion
	use file
	write "Started @ ",$zdate($horolog,"24:60:SS"),!
	set ^silly($job)=1
	zwrite ^silly($job)
	write "Ended @ ",$zdate($horolog,"24:60:SS"),!
	close file
	quit
err	for lev=$stack:-1:0 quit:$stack(lev,"PLACE")[("^"_$text(+0))
	set loc=$stack(lev,"PLACE"),next=$zl_":"_$p(loc,"+")_"+"_($piece(loc,"+",2)+1)_"^"_$piece(loc,"^",2)
	set status=$zstatus
	if status'[$get(expect)!(""=$get(expect)),$increment(cnt) set io=$i write !,$stack(lev,"MCODE"),!,$zstatus use io xecute act
	set $ecode=""
	zgoto @next
	write !,"oops",!,$zstatus
	zhalt 4	; in case of error within err
