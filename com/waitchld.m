;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
;	Copyright 2003, 2013 Fidelity Information Services, Inc	;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
waitchld(numchild,maxwait);
	;
	; Requirements : current global directory has only one region
	; this waits until either of the following conditions becomes false
	;	(i) "Reference count" (number of attached processes to the database) in the fileheader is > "numchild"
	;	(ii) We have waited for more than "maxwait" seconds
	; Returns
	;	current number of processes attached (excluding the DSE done here)
	; Note : this relies on the output format of DSE DUMP -FILE
	;
	new unix,dsefile,refcnt,dszsystr,totalwait,line,i,fields
	set numchild=numchild+1	; add 1 for the DSE process that attaches to the database below
	set unix=$ZVersion'["VMS"
	set dsefile="dsedump.out"
	if unix  do
	.	set dszsystr="$gtm_dist/dse dump -file |& grep ""Reference count"" >& "_dsefile
	.	set dszsystr=dszsystr_"; $convert_to_gtm_chset "_dsefile
	if 'unix set dszsystr="@gtm$test_common:dsedump.com"
	set refcnt=numchild
	set totalwait=0
	for  do  quit:(refcnt'>numchild)!(totalwait>maxwait)  hang 1
	.	zsystem dszsystr
	.	set file=dsefile
	.	open file
	.	use file
	.	read line
	.	use $p
	.	close file
	.	set *fields=$$SPLIT^%MPIECE(line)
	.	if ""=fields(3) write "TEST-E-NODSEOUTPUT Dse output came out empty. Halting wait cycle",! set totalwait=maxwait
        .       else  set refcnt=fields(3)
	.	set totalwait=totalwait+1
	write !
	quit refcnt-1
