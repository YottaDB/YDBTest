;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information 		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8142 ; Attempt to provoke a race between db_init and rundown among mumps processes
	for i=1:1:20  do children
	halt

children
	; Note: This routine deliberately does not use globals so as to allow the child processes to init/rundown the database.
	new c,s,key,lhandle,chandle,shandle,cpid,ch,cjob
	set s="s"
	open s:::"SOCKET"
	use s
	open s:(LISTEN="children.sock:LOCAL":IOERROR="TRAP":DELIMITER=$c(10))::"SOCKET"
	set key=$key,lhandle=$piece(key,"|",2)
	for c=1:1:40  do
	. use s
	. open s:(CONNECT="children.sock:LOCAL":IOERROR="TRAP":DELIMITER=$c(10))::"SOCKET"
	. set key=$key,chandle=$piece(key,"|",2)
	. write /wait(5)
	. else  use $P  write "TEST-E-TIMEOUT, wait timed out",!  zshow "*"  halt
	. set key=$key,shandle=$piece(key,"|",2)
	. use s:DETACH=shandle
	. job @("child:(INPUT=""SOCKET:"_shandle_""":OUTPUT=""SOCKET:"_shandle_""":ERROR=""child_"_i_"_"_c_".err"")")
	. set ch(c)=chandle,cjob(c)=$zjob
	for c=1:1:40  do
	. ; Read the pid from the child to make sure it is up.
	. use s:SOCKET=ch(c)
	. read cpid:300
	. else  use $P  write "TEST-E-TIMEOUT, socket read timed out",!  zwrite c,cjob(c)  zshow "D"  do cleanup
	. if cpid'=cjob(c)  use $P  write "TEST-W-PIDMISMATCH, "_$zwrite(cpid)_" vs "_$zwrite(cjob(c)),!
	close s:(SOCKET=lhandle:DELETE)
	; Close the socket device to close all our socket endpoints, causing the child jobs to exit.
	close s
	; Start another job to a) race to connect while others are disconnecting, and b) clean up after child jobs.
	job @("cleanup:(ERROR=""cleanup_"_i_".err"")")
	do ^waitforproctodie($zjob,300)
	quit

child
	use $io:DELIMITER=$c(10)
	tstart ()
	set ^pids($incr(^pidcount))=$job
	tcommit
	write $job,!
	read x:300
	else  set errstr="TEST-E-TIMEOUT, expected an error, but got a timeout"
	if x'=""  set errstr="TEST-E-UNEXPECTEDVALUE, expected empty, got "_$zwrite(x)
	if $data(errstr)  do
	. set err="child_"_$job_".err"
	. open err
	. write errstr,!
	. close err
	. halt
	halt

cleanup
	merge localpids=^pids
	do waitforalltodie^waitforproctodie(.localpids,300)
	kill ^pidcount,^pids
	halt
