;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
incrgv4;
	; create 8 globals ^INCREMENTGV1, ^INCREMENTGV2, ... ^INCREMENTGV8
	; do $increment(^INCREMENTGVi(100)) with multiple processes
	; concurrently create/kill records ^INCREMENTGVi with subscripts randomly below and above 100
	; this way create a constant motion in the tree for ^INCREMENTGVi(100) thereby exercising the concurrency validation logic
	; this is to test that $incr of a key that is constantly being moved by concurrent updates works fine
	;
	set ^waittime=15+$r(15) ; time (in seconds) that jobbed off children run for before they stop gracefully
	set ^incrproc=6	; number of processes concurrently doing $INCREMENT
	set ^updproc=2	; number of processes concurrently doing SET/KILL
	set ^numgbls=^incrproc+^updproc
	set ^gblname="INCREMENTGV"
	set ^updproc1=6	; number of processes concurrently doing updates in child1
	set ^z1=0
	set ^stop=0
	set ^gdscert=$r(1) ; whether view "GDSCERT" is turned on or not
	;
	set ^incrindx=100	; the subscript that is used for $INCREMENT, keys below and above this will get set/killed
	for i=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_i kill @global7890123456789012345678901 set @global7890123456789012345678901@(^incrindx)=0
	kill ^finalcnt
	for i=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_i set ^finalcnt(global7890123456789012345678901)=0
	;
	set jmaxwait=0
	set jobid=1
	do ^job("child^incrgv4",^incrproc,"""""")
	set jobid=2
	do ^job("update^incrgv4",^updproc,"""""")
	set jobid=3
	do ^job("child1^incrgv4",^updproc1,"""""")
	;
	hang ^waittime
	; Ensure that all ^INCREMENTGVi(100) have been increased at least once before stopping the children.  Will wait a maximum of 5 minutes.
	set waittimeloop=0
	for i=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_i quit:@global7890123456789012345678901@(^incrindx)=0
	for loop=1:1:10  quit:i=^numgbls  do
	.	hang 30
	.	for i=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_i quit:@global7890123456789012345678901@(^incrindx)=0
	set ^stop=1	; signal children to stop
	;
	set jobid=1
	do wait^job	; wait for children to stop
	set jobid=2
	do wait^job	; wait for children to stop
	set jobid=3
	do wait^job	; wait for children to stop
	;
	do checkdb	; do application level data integrity check
	;
	quit

child	;
	do init
	new numgbls,gblname,global7890123456789012345678901,finalcnt,index,tmp,incrindx
	set numgbls=^numgbls
	set gblname=^gblname
	set incrindx=^incrindx
	for index=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_index set finalcnt(global7890123456789012345678901)=0
	for index=1:1:^numgbls  set global789012345678901234567890="this fails"
	for index=1:1 quit:^stop=1  do
	.	set global7890123456789012345678901="^"_gblname_(index#numgbls+1)
	.	set global789012345678901234567890="this should fail"
	.	; give non-TP 60%, TP 40%
	.	set istp=($random(5)<2)
	.	if istp=1 tstart ():(serial:transaction="BA")
	.	set x=$incr(@global7890123456789012345678901@(incrindx))
	.	set @global7890123456789012345678901@("y",x)=x+1
	.	set @global7890123456789012345678901@("z",x)=-x
	.	; set finalcnt(global7890123456789012345678901)=finalcnt(global7890123456789012345678901)+1
	.	if istp=1 tcommit
	.	set tmp=$incr(finalcnt(global7890123456789012345678901))
	.	; Do whatever "update^incrgv4" does to try trigger DBKEYORD error scenario (C9J07-003162)
	.	; as that requires the process which does the $INCR (and has the bad clue) to
	.	; do the next update in the same vicinity (using the first_rec part of the clue) to
	.	; create a DBKEYORD integ error situation
	.	set subscrpt=$random(12)*(incrindx/10)+1
	.	set @global7890123456789012345678901@(subscrpt)=$justify(subscrpt,200)
	for index=1:1:^numgbls  set global7890123456789012345678901="^"_^gblname_index set tmp=$incr(^finalcnt(global7890123456789012345678901),finalcnt(global7890123456789012345678901))
	quit
child1	;
	; x1 is passed as parameter to TSTART, y1 is not passed.
	; After every restart, initial value of x1 will be restarted
	; at the end y1-rcount=x1
	do init
	set x1=0,y1=0,rcount=0
	for index=1:1 quit:^stop=1  do
	. TSTART (x1)
	. s x1=$increment(x1)
	. s y1=$increment(y1)
	. if $TRESTART set rcount=rcount+1
	. s tmp=$incr(^z1)
	. TC
	if y1-rcount'=x1 write "TEST-E-VERFAIL: y1:rcount:x1=",y1,":",rcount,":",x1,!
	quit

update	;
	do init
	new numgbls,gblname,global7890123456789012345678901,subscrpt,action,i,index,incrindx
	set numgbls=^numgbls
	set gblname=^gblname
	set incrindx=^incrindx
	for index=1:1 quit:^stop=1  do
	.	set global7890123456789012345678901="^"_gblname_(index#numgbls+1)
	.	; e.g. if "incrindx" is 100, then create/kill subscripts 1, 11, 21, ..., 91, 101, 111 randomly
	.	; 	the idea is to create/kill subscripts below and above the subscript that is used for $incr
	.	set subscrpt=$random(12)*(incrindx/10)+1
	.	set action=$random(2)
	.	if action=0 set @global7890123456789012345678901@(subscrpt)=$justify(subscrpt,200)	; create with 50% probability
	.	if action=1 kill @global7890123456789012345678901@(subscrpt)				; kill   with 50% probability
	quit

init	;
	if $get(^gdscert)=1  view "GDSCERT":1
	quit

checkdb	;
	new fl,index,global789012345678901234567890,global7890123456789012345678901,finalcnt,ybeg,zbeg,yend,zend,flg
	set fl=0
	set incrindx=^incrindx
	set gblname=^gblname
	for index=1:1:^numgbls  do
	.	set global7890123456789012345678901="^"_^gblname_index
	.	set finalcnt=^finalcnt(global7890123456789012345678901)
	.	if @global7890123456789012345678901@(incrindx)'=finalcnt do
	.	.	write "Verify Fail: ",global7890123456789012345678901,"(",incrindx,")=",@global7890123456789012345678901@(incrindx)," Expected=",finalcnt,! set fl=fl+1
	.	set ybeg=$order(@global7890123456789012345678901@("y",""))
	.	if ybeg'=1 write "Verify Fail: global7890123456789012345678901:",global7890123456789012345678901," ybeg=",ybeg," Expected=1",! set fl=fl+1
	.	set zbeg=$order(@global7890123456789012345678901@("z",""))
	.	if zbeg'=1 write "Verify Fail: global7890123456789012345678901:",global7890123456789012345678901," zbeg=",zbeg," Expected=1",! set fl=fl+1
	.	for i=1:1:finalcnt  do
	.	.	if $get(@global7890123456789012345678901@("y",i))'=(i+1) write "Verify Fail: ",global7890123456789012345678901,"(""y"",",i,")=",$get(@global7890123456789012345678901@("y",i))," Expected=",(i+1),! set fl=fl+1
	.	.	if $get(@global7890123456789012345678901@("z",i))'=-i write "Verify Fail: ",global7890123456789012345678901,"(""z"",",i,")=",$get(@global7890123456789012345678901@("z",i))," Expected=",-i,! set fl=fl+1
	.	set yend=$order(@global7890123456789012345678901@("y",i))
	.	set zend=$order(@global7890123456789012345678901@("z",i))
	.	if yend'="" write "Verify Fail: global7890123456789012345678901:",global7890123456789012345678901," yend=",yend," Expected=""""",! set fl=fl+1
	.	if zend'="" write "Verify Fail: global7890123456789012345678901:",global7890123456789012345678901," zend=",zend," Expected=""""",! set fl=fl+1
	if fl=0 write "--> incrgv4 : checkdb PASSED.",!
	else  write "--> incrgv4 : checkdb FAILED.",!
	quit
