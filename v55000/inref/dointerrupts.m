;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2012, 2013 Fidelity Information Services, Inc	;
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
; This script is used by GTM6813 subtest and verifies that argument passing works
; correctly even when interrupted.
dointerrupts
	write "Starting...",!
	set $etrap="zshow ""*"" halt"

	; specify various configuration parameters
	set ^intrptdelay=0.0001
	set limit=10000000
	set minintrptcnt=100,minelapsedtime=30

	; prepare iterators and counters
	set intrptcnt=0
	set x0=0,x1=0,x2=0,x3=0,x4=0,x5=0
	set y0=0,y1=0,y2=0,y3=0,y4=0,y5=0
	set sum=0
	set i=0

	; populate various label calls for interrupter
	set call(0)="label0()"
	set call(1)="label0"
	set call(2)="label1(-5,-10)"
	set call(3)="label1(-8)"
	set call(4)="label1()"
	set call(5)="label2"
	set call(6)="label3(15,16,17,18,19,20,21,22,23,24,25,26)"
	set call(7)="label3(15,16,17,18,19,20)"
	set call(8)="label4"

	; prepare to start the interrupter job
	set ^quit=0
	set ^continue=0
	lock +^intrptlock
	set jmaxwait=0	; do not wait for the job to finish immediately
	set jnoerrchk=1 ; do not include interference jobs output in the error check
	set ^mainpid=$job
	set $zinterrupt="do handler^"_$text(+0)
	do job^job("interrupter^dointerrupts",1,"""""")

	; wait for the interrupter to get ready
	for  quit:^continue  hang 0.25

	set starttime=$horolog
	; launch the interrupter and start making calls with arguments
	lock -^intrptlock
	; Exit the loop if at least "minintrptcnt" interrupts have been seen AND "minelapsedtime" seconds have elapsed
	for i=1:1:limit quit:(intrptcnt>minintrptcnt)&(minelapsedtime>$$^difftime($horolog,starttime))  do adder(i,i*2,i*3,i*4,i*5)

	write "Stopping...",!

	; stop the interrupter
	set ^quit=1
	do wait^job

	; calculate the reference value
	set:intrptcnt>maxintrptcnt i=i-1
	set sum=(1+i)*(i\2)
	if i#2 set sum=sum+(i\2)+1

	; verify that interrupts were handled properly
	if (x4'=x5)!((x0+x1+x2+x3+x4)'=intrptcnt) do
	.	write "FAIL: interrupt counts do not add up:",!
	.	write "  interrupt count: "_intrptcnt,!
	.	write "  x0: "_x0,!
	.	write "  x1: "_x1,!
	.	write "  x2: "_x2,!
	.	write "  x3: "_x3,!
	.	write "  x4: "_x4,!
	.	write "  x5: "_x5,!

	; verify that all arguments were passed properly
	if (y0'=sum)!(y1'=(sum*2))!(y2'=(sum*3))!(y3'=(sum*4))!(y4'=(sum*5)) do
	.	write "FAIL: one or more arguments were not passed correctly:",!
	.	write "  count: "_i,!
	.	write "  sum: "_sum,!
	.	write "  y0: "_y0,!
	.	write "  y1: "_y1,!
	.	write "  y2: "_y2,!
	.	write "  y3: "_y3,!
	.	write "  y4: "_y4,!
	.	write "  y5: "_y5,!
	.	if $data(error) zwrite error
	write "  interrupt count: "_intrptcnt,!
	write "  iteration count: "_i,!
	write "All done.",!
	quit

interrupter
	set signal=$ztrnlnm("sigusrval")
	set ^continue=1
	set mainpid=^mainpid
	set intrptdelay=^intrptdelay
	lock +^intrptlock
	for  quit:^quit  do
	.	if $zsigproc(mainpid,signal)
	.	hang intrptdelay*(1+$random(10))
	quit

adder(i0,i1,i2,i3,i4)
	; Check if actual parameters i1 thru i4 are what we expect. If not, record the difference in "error" local.
	; This local will be displayed at the end of the test.
	set:(2*i0'=i1) error(i0,2)=(2*i0-i1)
	set:(3*i0'=i2) error(i0,3)=(3*i0-i2)
	set:(4*i0'=i3) error(i0,4)=(4*i0-i3)
	set:(5*i0'=i4) error(i0,5)=(5*i0-i4)
	set y0=y0+i0
	set y1=y1+i1
	set y2=y2+i2
	set y3=y3+i3
	set y4=y4+i4
	quit

handler
	set intrptcnt=intrptcnt+1
	do @("@call("_$random(9)_")")
	quit

label0()
	set x0=x0+1
	quit

label1(x,y)
	set x1=x1+1
	quit

label2
	set x2=x2+1
	quit

label3(o,p,q,r,s,t,u,v,w,x,y,z)
	set x3=x3+1
	quit

label4()
	set x4=x4+1
	do label5(1,2)
	quit

label5(x,y)
	set x5=x5+1
	set x=y
	quit
