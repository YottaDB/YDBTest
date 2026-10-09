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
; YDB#1302 : An error that interrupts a LOCK must not make a later LOCK + of a name in the interrupted LOCK return
; success without acquiring that lock.
;
; Each label below is run by lock_err_cleanup-ydb1302.csh.
;
ydb1302	;
	quit

sub2long	; LOCK (alock,alock(<256 bytes>)) issues LOCKSUB2LONG, then LOCK +alock:5
	new zerr
	do try("multi^ydb1302","LOCKSUB2LONG")
	lock +alock:5
	do check("LOCK +alock:5","alock")
	lock
	quit

nested	; LOCK +(clock,dlock($$nest)), where $$nest does a LOCK, issues BADLOCKNEST, then LOCK +clock:5
	new zerr
	do try("outer^ydb1302","BADLOCKNEST")
	lock +clock:5
	do check("LOCK +clock:5","clock")
	lock
	quit

crit	; LOCK -(^a,^x), where the region of ^a shares LOCK crit with database crit and its file header is marked
	; corrupt, so releasing ^a issues DBFLCORRP after ^x has been released
	new zerr
	if $view("REGION","^a")'="AREG" write "WRONG : ^a maps to ",$view("REGION","^a"),", expected AREG",! quit
	if $view("REGION","^x")'="DEFAULT" write "WRONG : ^x maps to ",$view("REGION","^x"),", expected DEFAULT",! quit
	lock +(^a,^x):5
	if $test write "PASS : LOCK +(^a,^x):5 set $TEST to 1",!
	else  write "WRONG : LOCK +(^a,^x):5 set $TEST to 0, expected 1",! quit
	do dse("true","dse_corrupt.out")
	do try("decr^ydb1302","DBFLCORRP")
	write "PASS : the process continued after the error",!
	do dse("false","dse_uncorrupt.out")
	lock
	quit

untimed	; An untimed LOCK +ulock after an error interrupted a LOCK of ulock, while another process holds ulock. The
	; LOCK must wait until that process releases ulock, and then hold it.
	new zerr,child,i
	kill ^ready,^released
	job hold^ydb1302
	set child=$zjob
	for i=1:1:600 quit:$data(^ready)  hang 0.1
	if '$data(^ready) write "WRONG : the child process did not lock ulock within 60 seconds",! quit
	lock ulock:0
	if $test write "WRONG : LOCK ulock:0 got ulock while the child process holds it",! quit
	write "PASS : LOCK ulock:0 set $TEST to 0 while the child process holds ulock",!
	do try("ulong^ydb1302","LOCKSUB2LONG")
	lock +ulock
	if $data(^released) write "PASS : LOCK +ulock returned only after the child process released ulock",!
	else  write "WRONG : LOCK +ulock returned while the child process still held ulock",!
	do check("LOCK +ulock","ulock")
	lock
	for i=1:1:600 quit:'$zgetjpi(child,"isprocalive")  hang 0.1
	quit

ulong	lock (ulock,ulock($translate($justify("",256)," ","x")))
	quit

hold	; Lock ulock, hold it for 2 seconds, then set ^released and release it
	lock ulock
	set ^ready=1
	hang 2
	set ^released=1
	lock
	quit

decr	lock -(^a,^x)
	quit

dse(value,file)	; Set the CORRUPT_FILE field of the AREG file header to value
	zsystem "printf 'find -region=AREG\nchange -fileheader -corrupt_file="_value_"\n' | $ydb_dist/dse >& "_file
	if $zsystem write "WRONG : DSE CHANGE -FILEHEADER -CORRUPT_FILE=",value," returned status ",$zsystem,", see ",file,!
	else  write "PASS : DSE CHANGE -FILEHEADER -CORRUPT_FILE=",value," on AREG",!
	quit

multi	lock (alock,alock($translate($justify("",256)," ","x")))
	quit

outer	lock +(clock,dlock($$nest))
	quit

nest()	lock +elock
	quit 1

try(label,expect)	; Run label, which must issue the error expect, and unwind back here when it does
	new $etrap
	set $etrap="set zerr=$piece($piece($zstatus,"","",3),""-"",3),$ecode="""" zgoto "_$zlevel
	set zerr=""
	do @label
	if expect=zerr write "PASS : ",label," issued ",expect,!
	else  write "WRONG : ",label," issued [",zerr,"], expected ",expect,!
	quit

check(what,name)	; For a timed LOCK, $TEST must be 1. ZSHOW "L" must show the process holds name at level 1.
	new lks,i,found,timed
	set timed=(what[":")
	if timed,'$test write "WRONG : ",what," set $TEST to 0, expected 1",! quit
	zshow "l":lks
	set found=0
	for i=1:1 quit:'$data(lks("L",i))  set:lks("L",i)=("LOCK "_name_" LEVEL=1") found=1
	if found write "PASS : ",what,$select(timed:" set $TEST to 1 and",1:",")," the process holds ",name,!
	else  write "WRONG : ",what,$select(timed:" set $TEST to 1, but",1:" returned, but")," ZSHOW ""L"" does not show ",name," held",!
	quit

held	; Report whether another process holds the lock named on the command line
	new name
	set name=$zcmdline
	lock +@name:0
	write $select($test:"free",1:"held"),!
	quit
