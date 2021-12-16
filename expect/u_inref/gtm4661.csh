#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# gtm4661a 	[bahirs] 	GT.M process does not stuck if terminated with SIGTERM signal.

$gtm_tst/com/dbcreate.csh mumps 1
setenv TERM xterm
# Process does not stuck up after receiving TERM signal while running in background.
# Turn on expect debugging using "-d". The debug output would be in expect.dbg in case needed to analyze stray timing failures.
(expect -d $gtm_tst/$tst/u_inref/gtm4661a.exp > expect_4661a.out) >& expect_4661a.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect_4661a returned non-zero exit status"
endif
mv expect_4661a.out expect_4661a.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect_4661a.outx > expect_4661a_sanitized.outx
$gtm_tst/com/grepfile.csh 'YDB-F-FORCEDHALT' expect_4661a_sanitized.outx 1
@ proc_pid1 = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
# if process did not die after 2 min after receiving TERM signal, it indicates that the process is stuck up.
$gtm_tst/com/wait_for_proc_to_die.csh $proc_pid1 120
# wait for jobbed off process (that sends the TERM signal in gtm4661a.exp) to die
$gtm_exe/mumps -run waitforjobtodie^sigproc

# Verify that process sends only one SUSPENDING message to operator log after receiving TSTP signal.
set syslog_start = `date +"%b %e %H:%M:%S"`
(expect -d $gtm_tst/$tst/u_inref/gtm4661b.exp > expect_4661b.out) >& expect_4661b.dbg
if ($status) then
	echo "EXPECT-E-FAIL : expect_4661b returned non-zero exit status"
endif
mv expect_4661b.out expect_4661b.outx	# move .out to .outx to avoid -E- from being caught by test framework
perl $gtm_tst/com/expectsanitize.pl expect_4661b.outx > expect_4661b_sanitized.outx

@ proc_pid2 = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
$gtm_tst/com/wait_for_proc_to_die.csh $proc_pid2 120
# wait for jobbed off process (that sends the TSTP signal in gtm4661b.exp) to die
$gtm_exe/mumps -run waitforjobtodie^sigproc

$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt "" REQ2RESUME
$gtm_tst/com/grepfile.csh "YDB-I-SUSPENDING" test_syslog.txt 1 >&! grepresult.txt
$gtm_tst/com/grepfile.csh "YDB-I-REQ2RESUME" test_syslog.txt 1 >>&! grepresult.txt
$grep "is not present" grepresult.txt
@ msgcnt = `$grep -c "${proc_pid2}.*YDB-I-SUSPENDING" test_syslog.txt`
if (1 != $msgcnt) then
	echo "TEST-E-FAIL more than one SUSPENDING message in the oeprator log"
endif

$gtm_tst/com/dbcheck.csh
