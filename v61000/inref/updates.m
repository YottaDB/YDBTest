;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Helper script for v61000/intrpt_wcs_wtstart test, which fires up one white-box-test process ('wbox' label),
; one writer process ('writer' label), and several reader procesess ('reader' label). The white-box process
; ensures that all other processes are started before proceeding to continuous writes, also giving itself
; about a half-a-second headstart to be the first guy to acquire a flush timer. Upon invoking wcs_wtstart()
; function a certain number of times, the white-box process gets killed, which ultimately instructs the
; remaining processes to terminate.
writer
	write $job,!
	write "started",!
	set index=$piece($zcmdline," ",1)
	set wboxpid=$piece($zcmdline," ",2)
	if $increment(^pending,-1)
	lock +@("^l("_index_")")
	hang 0.5
	for i=1:1 do  quit:($zsigproc(wboxpid,0))
	.	hang ($random(11)/100)
	.	set ^a(i_$j)=$justify(i,4000)
	quit

reader
	write $job,!
	write "started",!
	set index=$piece($zcmdline," ",1)
	set wboxpid=$piece($zcmdline," ",2)
	if $increment(^pending,-1)
	lock +@("^l("_index_")")
	hang 0.5
	set subscript=""
	for  do  quit:($zsigproc(wboxpid,0))
	.	set subscript=$order(^a(subscript))
	quit

wbox
	set count=$zcmdline
	if $increment(count,-1)
	set ^pending=count
	write $job,!
	write "started",!
	for i=1:1:count lock +^l(i)
	for  quit:('^pending)  hang 0.1
	lock
	for i=1:1 set ^a(i)=$justify(i,4000)
	quit
