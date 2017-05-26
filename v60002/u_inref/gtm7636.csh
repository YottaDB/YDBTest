#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$MULTISITE_REPLIC_PREPARE 2
# Disable instance freeze to avoid dealing with freeze situations when GBLOFLOW is encountered.
unsetenv gtm_test_freeze_on_error
unsetenv gtm_test_fake_enospc
setenv gtm_test_spanreg 0	# The test expects a GBLOFLOW with a kind of updates. Spanning regions, would change the equation
$gtm_tst/com/dbcreate.csh mumps 3 125 1000 4096

# Set the white box test case parameters
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 90
if (! $?gtm_test_replay) then
	@ dbfilext_rand = 2 + `$gtm_exe/mumps -run rand 3`	# mmap() fail frequency for gdsfilext/wcs_recover
	echo setenv dbfilext_rand $dbfilext_rand >>&! settings.csh
endif
setenv gtm_white_box_test_case_count $dbfilext_rand

$MSR START INST1 INST2 RP
get_msrtime
set updproclog=RCVR_${time_msr}.log.updproc
# Make the secondary side have a smaller extension count forcing update process to definitely encounter the DBFILERR in debug mode
$MSR RUN INST2 '$MUPIP set -extension_count=50 -region "*"' >& chng_extension_count.out

# Start updates
$gtm_exe/mumps -run %XCMD 'do start^gtm7636'
set jobfile = *.mjo1

# Wait until interested events happen
unsetenv gtm_white_box_test_case_enable
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -message GBLOFLOW -duration 600 -log $updproclog"
$MSR RUN INST1 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -message MMREGNOACCESS -duration 600 -log $jobfile"

# Stop the updates
$gtm_exe/mumps -run %XCMD 'do stop^gtm7636'

# Filter out errors
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/check_error_exist.csh $updproclog GBLOFLOW"
$msr_err_chk $msr_execute_last_out GBLOFLOW >>&! capture_error.outx

# The *.mjo* files should have either a GBLOFLOW or DBFILERR followed by a MMREGNOACCESS error
set cnt1 = `$grep -c -E "GBLOFLOW|DBFILERR" $jobfile`
set cnt2 = `$grep -c -E "MMREGNOACCESS" $jobfile`
if ($cnt1 == 0 || $cnt2 == 0) then
	echo "TEST-E-FAIL, Did not see one of GBLOFLOW, DBFILERR or MMREGNOACCESS in $jobfile"
else
	$tst_gzip $jobfile
endif

# Since the update process died, shutdown the replication servers explicitly
$MSR STOP INST1
setenv msr_dont_chk_stat # Receiver exit status will be non-zero
$MSR STOP INST2 |& $grep -v "TEST-E-RF_SYNC"
$msr_err_chk $msr_execute_last_out "TEST-E-RF_SYNC" >> capture_error.outx
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/RCVR_SHUT_*.out "TEST-E-RCVR_SHUT" >>&! capture_error.outx

# Extracts won't match as the update process would have died earlier. So, don't bother with -extract
$gtm_tst/com/dbcheck.csh -noshut
