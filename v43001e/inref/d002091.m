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
d002091	;
	; Test that BOTH Nested and Flat jobs work fine without any errors or fd leaks
	do flat
	do nested
	quit
init	;
	; by default maxiter is the maximum # of iterations for BOTH flat and nested subtests
	; if an override is desired for the nested test, define it using nestedmaxiter variable
	; if an override is desired for the flat   test, define it using flatmaxiter variable
	Set $ecode="",$etrap="zshow ""*"" halt"
	set maxiter=1000
	if $zversion["HP-UX" set maxiter=500
	if $zversion["Solaris" set maxiter=500
	; On zOS, we have found that with encryption, there is a file descriptor leak (/dev/null). That together with
	; a gpg issue of not able to handle fd values > 256 causes the test to fail (see C9I09-003031 folder for details).
	; So in that case, limit # of iters in the nested subtest to 200 which we have verified works.
	; For the flat subtest we still want to go ahead with 500 so that is not overridden.
	if $zversion["OS390" set maxiter=500 if $ztrnlnm("test_encryption")="ENCRYPT" set nestedmaxiter=200
	if $zversion["Linux x86",$ztrnlnm("test_encryption")'="ENCRYPT" set maxiter=2500
	if '$data(flatmaxiter)  set flatmaxiter=maxiter
	if '$data(nestedmaxiter)  set nestedmaxiter=maxiter
	set jobtim=5
	set ^stop=0
	; In the flat subtest, spawn off jobs one after another.
	; Take care not to spawn off one by one as it will slow down the runtime of the test.
	; Also take care not to spawn off all at once as it could bring the system down to its knees or affect user job limits.
	; So spawn off 50 jobs at one time and wait for all of them to complete before spawning the next set.
	set flatmaxjobsatonetime=50
	quit
flat	;
	do init
	set jnoerrchk=1	; do not want error checking as that goes through zsystem which takes long for 1000s of iterations
			; anyways the test framework is going to check for errors
	set jmaxwait=0
	set jnolock=1
 	for jobstart=1:flatmaxjobsatonetime:flatmaxiter  do
	.	set jobid=jobstart
	.	do ^job("flatjob^d002091",flatmaxjobsatonetime,"""""")
	.	do wait^job
	if $get(^flatjobcnt)=flatmaxiter write "PASS D9C04002091 Flat",!
	else  write "FAIL D9C04002091 Flat",!  zsh "*"
	quit
flatjob	;
	Set $ecode="",$etrap="zshow ""*"" halt"
	set flatjobcnt=$incr(^flatjobcnt)	; use $incr since concurrent jobs might be doing the same thing
	quit
nested	;
	do init
	set ^jobcnt=0
	do nestjob(nestedmaxiter,jobtim)
	set numsleep=1800	; maximum hang is 1800 seconds i.e. 30 minutes
	for index=1:1:numsleep hang 1 quit:(($get(^jobcnt)=nestedmaxiter)!($data(^failjob)))  do
	.	set prevtime(index)=$h set prevcnt(index)=$get(^jobcnt)
	if $get(^jobcnt)=nestedmaxiter write "PASS D9C04002091 Nested",!
	else  do
	.	write "FAIL D9C04002091 Nested",!
	.	if 0=$data(^failjob) do
	.	.	write "Test timed out. Was this machine under heavy workload? MREP <timeout_fail_D9C04002091_nested>",!
	.	zsh "*"
	.	set ^stop=1
	.	set status=$$^waitchld(1,300)
	.	if status'=1  write "WAITCHLD-E-ERROR : ",status," processes still attached to the database"
	.	write "$h at the end = ",$h,!
	quit

nestjob(nestedmaxiter,jobtim)	;
	Set $ecode="",$etrap="zshow ""*"" halt"
	set jobcnt=$incr(^jobcnt)
	if ^stop=1  quit
	if jobcnt=nestedmaxiter quit  ; In case it works
	set jobargs="nestjob("_nestedmaxiter_","_jobtim_")::"_jobtim
	job @jobargs
	else  set ^failjob(jobcnt)="failed at iteration"_jobcnt ; this doesn't work in GTM
	quit
