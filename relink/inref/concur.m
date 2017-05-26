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

; This script exercises concurrent multi-process loading of randomly sized objects into shared memory. The program is run as follows:
;
;   mumps -run test1 100 0 16
;
; The 100 indicates the number of concurrent processes. The program starts 10 of them first, sleeps 1 second, starts another 10, and so on, until all 100 have
; been started. At the end it stops all 100 processes.
;
; Each process creates a randomly sized M program (say, obj38704.m, which suggests that the respective object file will be approximately 38K bytes in size) and
; issues a DO (i.e., do ^obj38704) of that routine. The database is needed to check if such an M program already exists, in which case it is not recreated; the
; DO is still issued. The object file created will not be exactly the estimated size, but between 1x and 2x that most of the times.
;
; If the second parameter of 0 is specified, we randomly choose whether to recreate M programs even if they already exist. This will cause multiple verisons of
; the same routine name to be loaded in shared memory by multiple processes (each one loading a different version) at the same time. When the second parameter
; is 1, each of these processes will examine the database to see what object files exist and randomly pick one of the available objects, thereby skipping the
; M-program-creation step.
;
; The third parameter is the power of two that marks the maximum (estimated) size of the generated object size.
concur
	set jmaxwait=0
	set jnolock=1	; or else one iteration of the "do ^job" below takes a long time to fire off causing a loaded system
	set maxjobs=+$piece($zcmdline," ",1)
	set njobs=$select(maxjobs<10:maxjobs,1:10)
	set maxjobs=maxjobs\njobs
	set ^nonewm=+$piece($zcmdline," ",2)
	set ^objsizepwr=+$piece($zcmdline," ",3)
	set stop=0
	set $zroutines="obj* "_$zroutines
	for jobid=1:1:maxjobs do  quit:stop
	.	set ^stop(jobid)=0
	.	do ^job("child^concur",njobs,""""_jobid_"""")
	.	set:((jobid#5=0)&$$shmsizeexceeded()) stop=1
	set actjobs=jobid
	; Let the jobs run until 0.5GB of shared memory is used. If that usage is not met within fifteen minutes, issue an error.
	for i=1:1:900 quit:stop  do
	.	if ('$$shmsizeexceeded()) hang 1
	.	else  set stop=1
	if ('stop) write "TEST-E-FAIL, Failed to attach 0.5GB shared memory usage in 900 seconds.",! zshow "A"
	for jobid=1:1:actjobs set ^stop(jobid)=1
	for jobid=1:1:actjobs do wait^job
	quit

shmsizeexceeded()
	zshow "A":zshow
	set total=0
	for j=1:1 quit:('$data(zshow("A",j)))  do
	.	set line=zshow("A",j)
	.	set:(line["Rtnobj shared memory") total=total+$$FUNC^%HD(+$piece(line,"shmlen: 0x",2))
	write "TEST-I-INFO, Total shared memory usage by this test is "_total,!
	quit (total>=2**29)

child(jobid)
	set nonewm=$get(^nonewm)
	if nonewm do
	.	merge tmp=^objsize
	.	set subs="" for  set subs=$order(tmp(subs),1)  quit:subs=""  set xobjsize($increment(nsubs))=subs
	set $zroutines="obj*(src)"
	for i=1:1 quit:^stop(jobid)=1  do
	.	if 'nonewm  do
	.	.	set objsize=$random(2**^objsizepwr)
	.	.	; Ensure objsize is non-zero and divisible by 16, which is the increment of object file sizes.
	.	.	set objsize=((objsize+16)\16)*16
	.	.	set newver=$random(2)
	.	.	if (newver!('$data(^objsize(objsize)))) do
	.	.	.	write "  Creating  obj"_objsize_".m",!
	.	.	.	lock +^objsize(objsize)
	.	.	.	if (newver!('$data(^objsize(objsize)))) do
	.	.	.	.	set file="src/obj"_objsize_".m"
	.	.	.	.	open file:(newversion)
	.	.	.	.	use file
	.	.	.	.	do geny(objsize)
	.	.	.	.	write " set ver="_$job,!
	.	.	.	.	close file
	.	.	.	.	set ^objsize(objsize)=""
	.	.	.	set ^objver(objsize)=$job
	.	.	.	lock -^objsize(objsize)
	.	else  do
	.	.	set j=$random(nsubs)
	.	.	set objsize=xobjsize(j+1)
	.	write "i = ",i," : objsize = ",objsize,!
	.	set rtn="obj"_objsize
	.	write " do "_rtn,!
	.	lock +^objsize(objsize)
	.	do ^@rtn
	.	if (ver'=^objver(objsize)) write "$h = ",$horolog," : ver=",ver," : ^objver(",objsize,") = ",^objver(objsize),!
	.	lock -^objsize(objsize)
	.	hang 0.1
	zshow "A" ; get a snapshot of the relinkctl shared memory state just before we die
	quit

geny(size)
	new i
	for i=1:1 quit:size<16  do
	.	set linesize=$select(size<100:size,1:100)
	.	write " if """_i_$justify(1,linesize)_"""",!
	.	set size=size-linesize
	quit
