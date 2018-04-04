;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
D9K05002773
	new flop
	do ^echoline
	set $etrap="use $p w $zs,! set $ecode="""" halt"
	set flop=$random(2)
	if flop=0  do forward
	if flop=1  do backward
	set $etrap=""
	do pipe
	do ^echoline
	quit

init	;
	set ^stop=0
	set ^maxsubs=1000000
	set ^numjobs=5+$random(5)
	quit

forward	;
	set ^mode=0,file="fwd.outx"
	open file:newversion
	use file
	do init
	do ^job("forwardload^D9K05002773",^numjobs,"""""")
	close file
	quit

backward;
	set ^mode=-1,file="bwd.outx"
	open file:newversion
	use file
	do init
	do ^job("reverseload^D9K05002773",^numjobs,"""""")
	close file
	quit

check	;
	write $order(^GBL(""),^mode)
	quit

loadinit;
	set numsubs=^maxsubs\^numjobs	; use \ (instead of /) to avoid fractions
	set startsub=(numsubs*(jobindex-1))+1
	if jobindex'=^numjobs  set endsub=(numsubs*jobindex)
	else  set endsub=^maxsubs	; if last job, add any remaining subscripts (from the \ above) to it
	; Delay the start of some loading threads randomly (20% of the time)
	; This can create different patterns of data loading and exercise the block-split optimal fillfactor algorithm a lot more.
	if ($random(5)=4) set hang=1  hang 10
	set istp=$random(2)
	quit

reverseload;
	do loadinit
	set stepsize=-1
	set loopstart=endsub
	set loopend=startsub
	do load
	quit

forwardload	;
	do loadinit
	set stepsize=1
	set loopstart=startsub
	set loopend=endsub
	do load
	quit

load	;
	set numupds=endsub-startsub+1
	set i=loopstart
	for  quit:numupds=0  do
	.	; bunch updates randomly
	.	set thisbunch=1+$random(20)
	.	set numbunches=1+$r(10)
	.	set updstodo=(thisbunch*numbunches)
	.	if updstodo>numupds  set thisbunch=numupds,numbunches=1,updstodo=numupds
	.	set thisbunch(i)=thisbunch
	.	set numbunches(i)=numbunches
	.	for j=1:1:numbunches  do
	.	.	if istp  tstart ():(serial:transaction="BATCH")	; use BATCH to avoid wait for journal hardening
	.	.	for k=1:1:thisbunch  do
	.	.	.	set ^GBL(i)=$justify(i,90)
	.	.	.	set i=i+stepsize
	.	.	if istp  tcommit
	.	set numupds=numupds-updstodo
	zshow "*"
	quit

pipe
	new i,pstr,pipe,col,count
	set pipe="D9K05002773"

	open pipe:(command="$gtm_exe/mupip integ -full -subs=^GBL -r DEFAULT")::"pipe"
	use pipe

	for  quit:$zeof  read line if $piece(line," ",3)="^GBL"  quit
	for i=1:1:5  quit:$zeof  do
	.	read line use $p
	.	for j=1:1:$length(line," ")  quit:$piece(line," ",j)'=""
	.	set col=$piece(line," ",j)
	.	if $select(col="0":1,col="1":1,1:0) do
	.	.	kill count
	.	.	for j=1:1:$length(line," ")  if $piece(line," ",j)'="" quit:$increment(count)>3
	.	.	if $piece(line," ",j)<90  write line,!  set fail=1
	.	use pipe
	close pipe
	use $p
	if '$data(fail) write "PASS",!
	else  write "FAIL",!
	quit

gdefile
	;change -segment DEFAULT -file=mumps.dat
	;change -segment DEFAULT -block_size=16384
	;change -region DEFAULT -record_size=1000
	;change -segment DEFAULT -alloc=3000
	;change -segment DEFAULT -ext=3000
	quit
