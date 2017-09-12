#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test that autoswitch failure due to permissions on the directory containing the journal files is handled properly.
#
# Runs a number of imptp processes, waits for at least one journal switch, then chmod's the journal directory read-only.
# For non-replic, gtm_error_on_jnl_file_lost is set, so we expect all the imptp processes to exit with JNLEXTEND.
# For replic, gtm_test_freeze_on_error is configured, so we expect the instance to freeze.
# Restores write access to the journal directory and verifies that writes and reads proceed normally.

if ($?test_replic) then
	unsetenv gtm_test_fake_enospc
	setenv gtm_test_freeze_on_error 1
	setenv gtm_custom_errors $gtm_tools/custom_errors_sample.txt
	# The source server may get stuck on crit instead of reporting the freeze if reading from files, so disable jnlfileonly
	# and forced overflow.
	setenv gtm_test_jnlfileonly 0
	unsetenv gtm_test_jnlpool_sync
	$MULTISITE_REPLIC_PREPARE 2
else
	setenv gtm_error_on_jnl_file_lost 1
endif

set jnldir="jnldir"

echo ">>> Create database"

mkdir -p $jnldir
if ($?test_replic) then
	$MSR RUN INST2 mkdir -p $jnldir >& mkdir.out
endif

@ num_regions = 4

# Set autoswitch to the lowest setting to maximize switching
$gtm_tst/com/dbcreate.csh mumps $num_regions 125 1000 4096 2000 4096 2000 -jnl_auto=16384 -jnl_prefix=${jnldir}/ >& dbcreate.log

if ($?test_replic) then
	# Start creates the instance file, which we need for the set
	$MSR START INST1 INST2 RP >&! msr_start_`date +%H_%M_%S`.out
else
	$MUPIP set $tst_jnl_str -region "*" >& jnl_enable.out
endif

echo ">>> Start imptp"

setenv gtm_test_dbfill "IMPTP"
setenv gtm_test_jobcnt 20	# More jobs means more journal entries written when the switch fails
setenv gtm_test_jobid 1
$gtm_tst/com/imptp.csh >>&! imptp.out

@ logcount = $num_regions + 1	# Wait for at least one journal file switch

(cd $jnldir ; $gtm_tst/com/wait_for_n_jnl.csh -lognum $logcount -duration 300)

echo ">>> Set jnldir read-only"

chmod a-w $jnldir

if ($?test_replic) then
	@ sleepcnt = 0
	# $MUPIP replic -source -freeze returns an error status when the instance is frozen.
	# Loop until we get an error status ({ cmd } returns false) or time out.
	while ( { $MUPIP replic -source -freeze } ) >& /dev/null < /dev/null
		@ sleepcnt++
		if ($sleepcnt > 120) then
			echo "TEST-E-timeout waiting for instance freeze"
			break
		endif
		sleep 1
	end
	echo $sleepcnt > instfreeze_sleepcnt.txt
else
	@ jobnum=0
	set mjofiles=""
	while ($jobnum < $gtm_test_jobcnt)
		@ jobnum++
		set mjofiles="$mjofiles impjob_imptp1.mjo${jobnum}"
	end
	$gtm_tst/com/wait_for_log.csh -log "$mjofiles" -message 'JNLEXTEND|JNLSWITCHFAIL' -useE >& wfl.out
endif

ls -al $jnldir >& jnldir_files.out
lsof *.dat >& lsof.out

echo ">>> Set jnldir read-write"

chmod a+w $jnldir

if ($?test_replic) $gtm_exe/mupip replic -source -freeze=off

echo ">>> Update all regions"
$gtm_exe/mumps -run %XCMD 'set ^a($job)=$random(1000),^b($job)=$random(1000),^c($job)=$random(1000),^d($job)=$random(1000)'

echo ">>> Stop imptp"
$gtm_tst/com/endtp.csh

echo ">>> Update all regions again"
$gtm_exe/mumps -run %XCMD 'set ^a($job)=$random(1000),^b($job)=$random(1000),^c($job)=$random(1000),^d($job)=$random(1000)'

echo ">>> Final checks"

# We occasionally hit the JNLEXTEND in a kill, which skips the bitmap update, leading to DBMRKBUSY, so filter that out.
$gtm_tst/com/dbcheck_filter.csh >& dbcheck_msr.out

if ($?test_replic) then
	# The source may not always see the freeze, so ignore the check output.
	$gtm_tst/com/check_error_exist.csh SRC_${start_time}.log REPLINSTFROZEN >& check_src_frozen.outx
endif

@ jobnum=0
while ($jobnum < $gtm_test_jobcnt)
	@ jobnum++
	# Can't use check_error_exist.csh since not all errors will always occur in all files
	mv impjob_imptp1.mjo${jobnum} impjob_imptp1.xmjo${jobnum}x
	$grep -vE 'JNLEXTEND|JNLSWITCHFAIL' impjob_imptp1.xmjo${jobnum}x > impjob_imptp1.mjo${jobnum}
	mv impjob_imptp1.mje${jobnum} impjob_imptp1.xmje${jobnum}x
	$grep -vE 'JNLEXTEND|JNLCLOSE|NOTALLDBRNDWN|GVRUNDOWN' impjob_imptp1.xmje${jobnum}x > impjob_imptp1.mje${jobnum}
end

echo ">>> Done"
