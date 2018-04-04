#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
expect -f $gtm_tst/$tst/u_inref/gtm4661a.exp | tr '\r' ' ' >&! gtm4661a.expected

$gtm_tst/com/grepfile.csh 'YDB-F-FORCEDHALT' gtm4661a.expected 1
@ proc_pid1 = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`
# if process did not die after 2 min after receiving TERM signal, it indicates that the process is stuck up.
$gtm_tst/com/wait_for_proc_to_die.csh $proc_pid1 120

# Verify that process sends only one SUSPENDING message to operator log after receiving TSTP signal.
set syslog_start = `date +"%b %e %H:%M:%S"`
expect -f $gtm_tst/$tst/u_inref/gtm4661b.exp | tr '\r' ' ' >&! gtm4661b.expected

@ proc_pid2 = `$gtm_exe/mumps -run %XCMD 'write ^myjob'`

$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt "" REQ2RESUME
$gtm_tst/com/grepfile.csh "YDB-I-SUSPENDING" test_syslog.txt 1 >&! grepresult.txt
$gtm_tst/com/grepfile.csh "YDB-I-REQ2RESUME" test_syslog.txt 1 >>&! grepresult.txt
$grep "is not present" grepresult.txt
@ msgcnt = `$grep -c "${proc_pid2}.*YDB-I-SUSPENDING" test_syslog.txt`
if (1 != $msgcnt) then
	echo "TEST-E-FAIL more than one SUSPENDING message in the oeprator log"
endif

$gtm_tst/com/dbcheck.csh
