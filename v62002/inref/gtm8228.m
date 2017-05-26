;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2015 Fidelity National Information		;
; Services, Inc. and/or its subsidiaries. All rights reserved.	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gtm8228	;
	; GTM-8228 Test that releasing M-locks at process exit does not require crit
	;
	set ^readmaxtime=300 ; max 5 minutes before timing out fromm a PIPE READ in a loaded system
	;
	write "Start M program that acquires M locks and holds onto it until process exit",!
	set ^astop=0
	set jmaxwait=0
	do ^job("child^gtm8228",1,"""""")
	write "Wait for M program to hold the M lock",!
	for  quit:^astop=1  hang 0.01
	write "Verify child process does hold lock",!
	zsystem "$gtm_exe/lke show"
	;
	write "Do a DSE CRIT -SEIZE to hold crit",!
        set dev="gtmProc"
        open dev:(command="$gtm_exe/dse":exception="goto done")::"PIPE"
	use dev
	write "FIND -REG=DEFAULT",!
	write "CRIT -SEIZE",!
	for  read out:^readmaxtime quit:(out["Seized write critical section")
	;
	use $principal
	write "Signal M program to die while holding M lock",!
	set ^astop=2
	;
	do wait^job
	write "Verify child process was able to release lock",!
	zsystem "$gtm_exe/lke show -nocrit"	; use -nocrit since DSE still has crit
	write "Test PASS : Process was able to release M lock and exit without needing crit",!
	;
	write "Do DSE CRIT -RELEASE to release crit",!
	use dev
	write "CRIT -RELEASE",!
	write "QUIT",!
	for  read out:^readmaxtime
done    if '$zeof write !,$zstatus
        close dev
        quit

child	;
	lock +^holdontillexit
	set ^astop=1
	; wait for parent to signal that we can proceed with process exit
	for  quit:^astop=2  hang 0.01
	;
	quit

lketest
	set lkdev="lkeproc"
        open lkdev:(command="$gtm_exe/lke":write)::"PIPE"
	use lkdev
	write "show locks",!
	write "show locks",!
	close lkdev:timeout=60
	quit

mupiptest
	set mupdev="mupipproc"
        open mupdev:(command="$gtm_exe/mupip":write)::"PIPE"
	use mupdev
	write "integ",!
	write "mumps.dat",!
	close mupdev:timeout=60
	quit
