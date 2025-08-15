;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; $ZCMDLINE piece 1 : the HUPENABLE setting [child2] establishes with USE $PRINCIPAL
;			HUPENABLE	: USE $P:(HUPENABLE)
;			NOHUPENABLE	: USE $P:(NOHUPENABLE)
;			HUPTHENNOHUP	: USE $P:(HUPENABLE) followed by USE $P:(NOHUPENABLE)
;			NONE		: USE $P with no deviceparameter, so gtm_hupenable alone decides
;			HUPRESET	: run [hupreset], which checks that SOCKHANGUP implicitly
;					  reverts $PRINCIPAL to NOHUPENABLE
; $ZCMDLINE piece 2 : the test number, used to name the ZSHOW "D" output file
;
parent	;
	kill ^done,^sethupenable,^testnum
	set ^done=0
	set ^sethupenable=$piece($ZCMDLINE," ",1)
	set ^testnum=$piece($ZCMDLINE," ",2)
	write "Parent process pid = ",$j,!

	write "# Open a LISTENing socket",!
	set s="socket"
	open s:::"SOCKET"
	open s:(LISTEN="socket1:LOCAL":ATTACH="handle1":ioerror="trap")::"SOCKET"

	; The LISTENing socket has to exist before child1 tries to CONNECT to it, so job child1 only now.
	; Per-test output and error files: the JOB defaults are named for the routine, so each test would
	; overwrite the previous test's.
	write "# Job child1, which will CONNECT to the LISTENing socket",!
	set xstr="job child1:(OUTPUT=""child1"_^testnum_".mjo"":ERROR=""child1"_^testnum_".mje"")"
	xecute xstr
	set child1=$zjob
	write "child1 process pid = ",child1,!

	write "# Wait until child1's connection is accepted,",!
	write "# then job off child2 with the CONNECTED socket device as $PRINCIPAL",!
	use s
	write /wait($$MAXWAIT()/10)	; when this command returns, a connection has been accepted
	if ""=$key  use $p  write "TEST-E-TIMEOUT child1 did not connect within ",$$MAXWAIT()/10," seconds",!  quit
	set handle=$piece($key,"|",2)
	use s:(detach=handle)
	set xstr="job child2:(INPUT=""SOCKET:"_handle_""":OUTPUT=""SOCKET:"_handle_""":ERROR=""child2.mje"")"
	xecute xstr
	set child2=$zjob
	use $p
	write "child2 process pid = ",child2,!

	write "# Wait for jobbed off child2 and child1 processes to terminate",!
	for i=1:1:$$MAXWAIT()  quit:'$zgetjpi(child2,"ISPROCALIVE")  hang 0.1
	if $zgetjpi(child2,"ISPROCALIVE")  write "TEST-E-TIMEOUT child2 process ",child2," still alive after ",$$MAXWAIT()/10," seconds",!
	set ^done=1	; tell child1 to stop waiting, whether or not child2 terminated on its own
	for i=1:1:$$MAXWAIT()  quit:'$zgetjpi(child1,"ISPROCALIVE")  hang 0.1
	if $zgetjpi(child1,"ISPROCALIVE")  write "TEST-E-TIMEOUT child1 process ",child1," still alive after ",$$MAXWAIT()/10," seconds",!
	quit
	;
child1	;
	set s="socket"
	open s:::"SOCKET"
	open s:(CONNECT="socket1:LOCAL":ioerror="trap":DELIMITER=$C(10))::"SOCKET"
	use s
	; Hold the connection open until the parent signals that child2 is done. Otherwise child2
	; could see a SOCKHANGUP caused by its peer going away rather than by the SIGHUP under test.
	for i=1:1:$$MAXWAIT()  quit:^done  hang 0.1
	; USE $P first: the current device is still the socket, so writing here without switching would
	; send the text to child2 instead of to this process's JOB output file child1<testnum>.mjo, named
	; per test by the caller. The framework scans "*.mjo*" for "-E-", so a TEST-E-TIMEOUT line there
	; fails the subtest rather than letting it pass with a silent timeout.
	if '^done  use $p  write "TEST-E-TIMEOUT child1 gave up waiting for ^done after ",$$MAXWAIT()/10," seconds",!
	quit
	;
child2	;
	; This process starts with a CONNECTED socket device as $PRINCIPAL
	if "HUPRESET"=^sethupenable  goto hupreset
	if "HUPENABLE"=^sethupenable  do
	. use $p:(HUPENABLE)
	else  if "NOHUPENABLE"=^sethupenable  do
	. use $p:(NOHUPENABLE)
	else  if "HUPTHENNOHUP"=^sethupenable  do
	. use $p:(HUPENABLE)
	. use $p:(NOHUPENABLE)
	else  do
	. use $p

	do zshowd
	do sighup
	quit
	;
zshowd	; Record whether ZSHOW "D" reports HUPENABLE for $PRINCIPAL. This reports the recorded
	; HUPENABLE setting only. "zshow_devices.c" prints HUPENABLE whenever the global "hup_on" is
	; TRUE, without consulting the SIGHUP handler, so it does not show that a handler is armed.
	; The SOCKHANGUP check done by the caller is what shows that.
	set zf="zshowd_"_^testnum_".out"
	open zf:(newversion)
	use zf
	zshow "d"
	close zf
	use $p
	quit
	;
sighup	; Send SIGHUP to ourselves. $ZSIGPROC delivers the signal before it returns, so there is no
	; window to wait on: if SIGHUP is recognized, the HANG below is the transfer point at which
	; the SOCKHANGUP error is raised. With no error handler set, that terminates this process and
	; writes the error to child2.mje; [hupreset] below sets $ETRAP so it can carry on instead.
	if $zsigproc($j,1)
	hang 1
	quit
	;
hupreset ; A SOCKHANGUP implicitly reverts $PRINCIPAL to NOHUPENABLE, exactly as V7.0-002
	; documented for TERMHANGUP, so a second SIGHUP is ignored unless USE $P:(HUPENABLE) is
	; reissued. Walk through that, recording after each step whether ZSHOW "D" still reports
	; HUPENABLE for $PRINCIPAL.
	;
	; $ETRAP, not a device EXCEPTION, is what gets control here: mdb_condition_handler.c
	; consults the $PRINCIPAL device error_handler only when $PRINCIPAL is a terminal.
	set lf="hupreset_"_^testnum_".out"
	open lf:(newversion)
	set $etrap="do hupetrap^gtmf135133"
	use $p:(HUPENABLE)
	do log("after USE $P:(HUPENABLE)")
	do sighup					; SOCKHANGUP expected
	do log("after first SIGHUP")
	do sighup					; no error expected, HUPENABLE was reset
	do log("after second SIGHUP")
	use $p:(HUPENABLE)
	do log("after reissuing USE $P:(HUPENABLE)")
	do sighup					; SOCKHANGUP expected again
	do log("after third SIGHUP")
	close lf
	do zshowd
	quit
	;
hupetrap ; $ETRAP handler: record the error and dismiss it so that the caller of the frame that
	; took the error, that is [hupreset], resumes at the command after its "do sighup".
	; Log the error mnemonic alone, not the "%GTM-E-SOCKHANGUP" text: com/errors_catch.txt
	; catches the substring "-E-", so com/errors.csh would flag this .out file as an error.
	do log("trapped "_$piece($piece($zstatus,",",3),"-",3))
	set $ecode=""
	quit
	;
log(msg)	; Append msg to the log file, along with whether ZSHOW "D" reports HUPENABLE for $PRINCIPAL
	new hup,i,zd
	zshow "d":zd
	set hup="no",i=""
	for  set i=$order(zd("D",i))  quit:""=i  do
	. if zd("D",i)["OPEN SOCKET",zd("D",i)["HUPENABLE"  set hup="yes"
	use lf
	write msg,": ZSHOW ""D"" reports HUPENABLE = ",hup,!
	quit
	;
MAXWAIT()	; Iteration bound shared by every wait loop above: 600 * 0.1 seconds = 60 seconds
	quit 600
