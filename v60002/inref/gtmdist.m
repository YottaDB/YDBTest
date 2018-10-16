;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright 2013 Fidelity Information Services, Inc		;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test that JOB command uses the same mumps executable as that of parent to start the new mumps process.
; mumps process is started with the DEV version i.e. V990. Using posix API it changed the gtm_dist to current
; pro version and then started another mumps process through JOB command. Verify that JOB'ed process GT.M version
; is current pro version and not V990
gtmdist
	set curpro=$ztrnlnm("gtm_curpro")
	set currdist=$ztrnlnm("gtm_dist")
	set currmumps=currdist_"/mumps"
	set verno=$tr($piece($zversion," ",2),".-","")
	; just in case don't assume where verno is, iterate over the path to find it
	for i=$length(currdist,"/"):-1:1  quit:$piece(currdist,"/",i)=verno
	; now create a newdist path and swap versions
	set newdist=currdist
	set $piece(newdist,"/",i)=curpro
	; change $gtm_dist to newdist
	set retval=$&ydbposix.setenv("gtm_dist",newdist,1,.errno)
	; fire off job
	job test^gtmdist
	; wait for the job using waitchld^job. Need to set the below for it to work
	set jmaxwait=300,jobindex(1)=$zjob,njobs=1,jprint=0,jnoerrchk=1
	do waitchld^job
	; validate it
	do validate
	quit

	; write the equivalent of $gtm_verno and quit
test
	write $tr($piece($zversion," ",2),".-",""),!
	zsystem "ps -fp "_$job
	halt

	; read the version printed in MJO file and compare it to the current
	; version. PASS on match, FAIL + zshow on no match
validate
	set file="gtmdist.mjo"
	open file:readonly
	use file
	read version
	for i=1:1  read psinfo(i) set psinfo(i)=psinfo(i)_" " quit:$zeof
	close file
	use $p
	set psline=$$^%MPIECE(psinfo(2)," ",$char(0))
	set col=$length(psline,$char(0)),actual=$piece(psline,$char(0),col-2)
	if currmumps=actual write "PASS",!
	else  write "TEST-F-FAIL",! zshow "*"
	if curpro=version write "PASS",!
	else  write "TEST-F-FAIL",! zwrite
	quit
