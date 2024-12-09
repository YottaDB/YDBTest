#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2022-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# TEST : JNLPOOL OVERFLOW (6.11)
#
# This test wants to switch from reading the journal pool to reading journal files due to overflow so disable jnlfileonly
# and forced overflow.
setenv gtm_test_jnlfileonly 0
unsetenv gtm_test_jnlpool_sync
#
# enable noisolation
setenv gtm_test_noisolation TPNOISO
setenv sys_call_trace TRUE
#
# For this test buffer size is 1 MB
setenv tst_buffsize 1048576
set gtm_process = 5
#
if (! $?gtm_test_replay) then
	if ($gtm_test_do_eotf) then
		# Each reorg encrypt causes 2 switches of journal files. Since it is done continuously in a loop,
		# it results in a lot of journal files for the source server to read. Until GTM-4928 is fixed, limit alignsize to 32768 (16MB)
		# 16MB because, at least one test failed with 32MB align size. (Few with 128MB and almost all failures analyzed were with 256MB)
		if (32768 < $test_align) then
			setenv test_align 32768
			set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
			setenv tst_jnl_str $tstjnlstr
			echo '# tst_jnl_str modified by subtest'	>> settings.csh
			echo "setenv tst_jnl_str $tstjnlstr"		>> settings.csh
		endif
	endif
	# The routine updates.m generates globals of size 8064 bytes. So have record size greater than that if not spanning nodes
	@ blksz = 32256
	@ align_bytes = `expr $test_align \* 512`
	if ($?gtm_test_spannode) then
	       if ($gtm_test_spannode > 0) then
		       @ blksz = `$gtm_exe/mumps -run chooseamong 512 1024 2048 4096 8192 16128 32256`
	       endif
	endif
	echo '# blocksize set by subtest'	>> settings.csh
	echo "setenv blksz $blksz"		>> settings.csh
	if ($blksz >= $align_bytes) then
		while ($blksz >= $align_bytes && $test_align < 131072)
			@ test_align = `expr $test_align \* 2`
			@ align_bytes = `expr $test_align \* 512`
		end
		set tstjnlstr = `echo $tst_jnl_str | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
		setenv tst_jnl_str $tstjnlstr
		echo '# tst_jnl_str modified by subtest'	>> settings.csh
		echo "setenv tst_jnl_str $tstjnlstr"		>> settings.csh
	endif
endif

# Use 16384 global buffers to try and avoid 'G' (cdb_sc_lostcr) type restarts in the update process
# while clearing the backlog and hopefully speeding up the backlog clearing process and test runtime.
$gtm_tst/com/dbcreate.csh mumps -n_regions=6 -key=255 -rec=16128 -block=$blksz -global_buffer=16384

setenv portno `$sec_shell '$sec_getenv; cat $SEC_DIR/portno'`
setenv start_time `cat start_time`
set src_log_time = $start_time
#
# IMPTP with 16k record sizes consume a lot of disk space when spanning node testing is enabled
# It has no easy governor to control the rate of updates. Hence disable it from using spanning nodes.
# This is okay since nodes will anyways get spanned by updates.m based on the random block size chosen above.
setenv gtm_test_spannode 0
echo "# GTM Process starts in background..."
$gtm_tst/com/imptp.csh $gtm_process >&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
sleep 5
$gtm_tst/com/rfstatus.csh "BEFORE_RECEIVER_SHUT"
echo "# Force receiver to shut down..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR_SHUT.csh ""."" '' ""buffer_flush"" < /dev/null >>&! $SEC_SIDE/SHUT_${start_time}.out"

echo "# Run updates large enough to overflow the jnlbuffer"
$gtm_exe/mumps -run updates
$gtm_tst/com/srcstat.csh "BEFORE_SPLIT"
echo "# Create a new journal file on source side"
$MUPIP set -file $tst_jnl_str a.dat

echo "# Run the updates again after cutting new journal files"
$gtm_exe/mumps -run updates
$gtm_tst/com/srcstat.csh "BEFORE_RECEIVER_RESTART"

# SECONDARY (B) UP
setenv start_time `date +%H_%M_%S`
echo "# Restarting (B) as secondary..."
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/RCVR.csh "." $portno $start_time < /dev/null "">>&!"" $SEC_SIDE/START_${start_time}.out"
$gtm_tst/com/rfstatus.csh "RECEIVER_B_UP:"

echo "# Cut journal files on source side again"
$MUPIP set -file $tst_jnl_str mumps.dat
echo "# Run the updates while the receiver is trying to catchup"
$gtm_exe/mumps -run updates

echo "# Ensure the source server reads from journal files after jnlbuffer overflow"
echo "# If the message about reading from journal files doesnt appear in the SRC log, then the test should/will fail"
$gtm_tst/com/wait_for_log.csh -log SRC_${src_log_time}.log -message "Source server now reading from journal files" -duration 60

echo "# Stop IMPTP process in primary..."
$gtm_tst/com/endtp.csh

$gtm_tst/com/rfstatus.csh "Before_TEST_stops:"
echo "# Database check and Application level check"
$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/checkdb.csh
