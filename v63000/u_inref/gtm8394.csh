#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8394 [nars] GTMASSERT in mur_insert_prev.c line 148 using V62000 after YDB-F-MEMORY interrupted rollbacks
#

# This test runs with limited memory setting and glibc does dlopen() of certain libraries (e.g. libgcc_s.so.1) on the fly
# (instead of opening them as part of the dlopen of libc.so) and so it is possible if/when those libraries are needed
# (e.g. pthread_cancel is one place where we have seen it), we might not have enough memory for the dlopen. In that case,
# the following message is issued by libc.
#
#	libgcc_s.so.1 must be installed for pthread_cancel to work
#
# This message is issued on the terminal where this test was issued from even if the test stdout/stderr have been
# redirected to a file. This is because the above message is treated as a fatal libc error and those go through
# a special function that tries to open the terminal (if available) to log the error. The following env var
# overrides that logic and continue to log this error in stderr.
#
setenv LIBC_FATAL_STDERR_ 1
set gccabort = "libgcc_s.so.* must be installed for pthread_cancel to work"

setenv mupjnl_check_leftover_files 1	# check for leftover extract files from the many mupip_rollback.csh invocations below

echo ">>> journal enable is done in this test. So let's not randomly enable journaling in dbcreate.csh"
setenv gtm_test_jnl NON_SETJNL
#
echo ">>> This test can only run with BG access method, so let's make sure that's what we have"
source $gtm_tst/com/gtm_test_setbgaccess.csh

echo ">>> This test requires BEFORE_IMAGE so set that unconditionally"
source $gtm_tst/com/gtm_test_setbeforeimage.csh

setenv gtm_repl_instance mumps.repl
setenv gtm_repl_instname INSTANCE1

echo ">>> Create databases for AREG BREG and DEFAULT"
$gtm_tst/com/dbcreate.csh mumps 3

echo ">>> Start passive source server and enable instance for local updates"
$gtm_tst/com/passive_start_upd_enable.csh >>& passive_start.out

echo ">>> Enable replication on AREG BREG and DEFAULT. Use minimum autoswitchlimit to exercise more journal switches"
# Redirect output to file since output order depends on ftok key order of regions which could be non-deterministic
$MUPIP set -replication=on -journal="enable,on,before,auto=16384" -reg "*" >& mupip_set_jnl.log

echo ">>> Do 100000 updates to BREG and DEFAULT but not AREG"
$GTM << GTM_EOF
	do ^gtm8394
GTM_EOF

echo ">>> Shut down passive source server"
$MUPIP replic -source -shutdown -timeout=0 >>& passive_stop.out

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before cp/mv of dat files

echo ">>> Save db/jnl to bak subdirectory"
$gtm_tst/com/backup_dbjnl.csh bak "*.gld *.repl *.dat *.mjl*" cp nozip

# The test can generate core files from mupip and/or tcsh due to out-of-memory issues.
# Cores from mupip are renamed explicitly in the test below.
# With gtm_mupjnl_parallel != 1, it is possible multiple mupip processes generate YDB-F-MEMORY so multiple mupip cores are possible.
# Cores from tcsh (and anything else unexpected) are handled by moving them into "*_coredir" directories
# this way later stages of this test dont get confused (every stage assumes no core files left over from previous stage).
# The test framework will anyways catch these cores (from "*_coredir") and issue a test failure if they are not from "tcsh"

# An out-of-memory pattern could be a YDB-F-MEMORY error OR a YDB-E-SYSCALL error from shmat.
set oompattern = "YDB-F-MEMORY|%YDB-E-SYSCALL, Error received from system call shmat"

echo ">>> Find one value of <limit vmemoryuse> that will cause a YDB-F-MEMORY error in the forward phase of rollback"
# Phase 1 : Towards that first find out a value of <limit vmemoryuse> that causes rollback to succeed but half of it causes failure
echo "Phase 1" >>! rollback_filename_order.txt
set mem = 32768  # start out with 32Mb as the vmemoryuse limit and use binary search to figure it out
@ max = 0
while (1)
	# Since we are limiting vmemoryuse for the rollback, various YDB-E-xxx messages are possible.
	# All we care about is no cores which the test framework will anyways check. So it is okay to redirect this to .outx
	# instead of .out (that way test framework will not worry about the rollback output for "YDB-E-xxx"
	set file=rollback_1_${mem}
	echo $file.outx >>! rollback_filename_order.txt
	cp bak/* .
	$gtm_tst/$tst/u_inref/gtm8394_helper.sh $mem >>& $file.outx
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before cp/rm of dat files
	rm -f *.gld *.repl *.dat *.mjl*
	$grep -qE "YDB-F-MEMORY|$gccabort" $file.outx
	if (0 == $status) then
		# move core file (from FATAL YDB-F-MEMORY) to avoid test framework from treating this as a test failure
		@ num = 1
		foreach corefile (core*)
			mv $corefile ${file}_${num}_$corefile >>& mv_core_$file
			@ num++
		end
	endif
	# Check if there are non-GT.M cores and if so move them out of the way for the next stage of the test
	set nonomatch; set cores=(core*); unset nonomatch
	if ("$cores" != "core*") then
		if (! -e ${file}_coredir) then
			mkdir ${file}_coredir
		endif
		mv core* ${file}_coredir # the expectation is that these cores are from "tcsh" (we have no control over these)
	endif
	$grep -q "JNLSUCCESS" $file.outx
	if (0 == $status) then
		@ max = $mem
		@ mem = $mem / 2
		continue
	else if ($max != 0) then
		break
	else
		@ mem = $mem * 2
	endif
end
# Phase 2 : Find value of <limit vmemoryuse> that causes rollback to fail with YDB-F-MEMORY in forward processing phase
echo "Phase 2" >>! rollback_filename_order.txt
@ end = $max
@ start = $max / 2
while (1)
	# For the same reasons as Phase 1, we use .outx file instead of .out here
	@ mid = ($start + $end) / 2
	set file=rollback_2_${mid}
	echo $file.outx >>! rollback_filename_order.txt
	cp bak/* .
	$gtm_tst/$tst/u_inref/gtm8394_helper.sh $mid >>& $file.outx
	rm -f *.gld *.repl *.dat *.mjl*
	# See test/v62000/u_inref/gtm8047.csh for comment on why we need to also search for ENO12 in addition to YDB-F-MEMORY
	$grep -Eq "$oompattern|SYSTEM-E-ENO12|Cannot allocate memory|$gccabort" $file.outx
	if (0 == $status) then
		# Found a setting that causes YDB-F-MEMORY or a memory-related error.
		$grep -qE "YDB-F-MEMORY|$gccabort" $file.outx
		if (0 == $status) then
			# move core file (from FATAL YDB-F-MEMORY) to avoid test framework from treating this as a failure
			@ num = 1
			foreach corefile (core*)
				mv $corefile ${file}_${num}_$corefile >>& mv_core_$file
				@ num++
			end
		endif
		# Check if error happened in forward phase. If so, we are done.
		$grep -q "Forward processing started" $file.outx
		if (0 == $status) then
			break
		else
			# Increase memory limit so we proceed further to forward recovery and get memory error there.
			@ start = $mid
		endif
	else
		$grep -q "JNLSUCCESS" $file.outx
		if (0 == $status) then
			# Rollback was successful, so decrease the upper limit
			@ end = $mid
		else
			# Rollback failed, but not with the expected error (it could even be tcsh error right at the start of rollback), so increase the lower limit
			@ start = $mid
			# Check if there are non-GT.M cores and if so move them out of the way for the next stage of the test
			set nonomatch; set cores=(core*); unset nonomatch
			if ("$cores" != "core*") then
				if (! -e ${file}_coredir) then
					mkdir ${file}_coredir
				endif
				mv core* ${file}_coredir # the expectation is that these cores are from "tcsh" (we have no control over these)
			endif
		endif
	endif
	@ midnew = ($start + $end) / 2
	if ($mid == $midnew) then
		echo "Values of start: $start and end: $end are (almost) the same"
		echo "This means the test was not able to find a value of <limit vmemoryuse> that causes rollback to fail with YDB-F-MEMORY in forward processing phase"
		echo "Check rollback_filename_order.txt and rollback_2_*.outx files for the output of each of the rollback attempts."
		echo "Exiting test now"
		exit 1
	endif
	# Check if there are non-GT.M cores and if so move them out of the way for the next stage of the test
	set nonomatch; set cores=(core*); unset nonomatch
	if ("$cores" != "core*") then
		if (! -e ${file}_coredir) then
			mkdir ${file}_coredir
		endif
		mv core* ${file}_coredir # the expectation is that these cores are from "tcsh" (we have no control over these)
	endif
end

echo ">>> Induce out-of-memory error in first rollback by setting vmemoryuse to GTM_TEST_DEBUGINFO [$mid]"
cp bak/* .  # Restore db/jnl from bak subdirectory before first YDB-F-MEMORY rollback
(limit vmemoryuse $mid; $gtm_tst/com/mupip_rollback.csh "" -back -verbose -resync=50001 "*" >& rollback1.out)
$gtm_tst/com/backup_dbjnl.csh bak1 "*.gld *.repl *.dat *.mjl*" cp nozip # Dont use "mv". Want next rollback to use this db/jnl

echo ">>> Verify out-of-memory error in first rollback (logfile = rollback1.out)"
$gtm_tst/com/check_error_exist.csh rollback1.out "$oompattern" >>& check_error_rollback1.outx
if ($status) then
	echo "TEST-E-VERIFY : Out-of-memory error verification failed. See rollback1.out and check_error_rollback1.outx"
endif
# It is possible we optionally see "SYSTEM-E-ENO12", "YDB-E-MUNOACTION" and/or "SYSTEM-E-ENO11" messages
# along with the "YDB-F-MEMORY message. If so filter those out as well to avoid the test framework from catching them.
foreach message ("YDB-E-MUNOACTION" "SYSTEM-E-ENO12" "SYSTEM-E-ENO11")
	$gtm_tst/com/check_error_exist.csh rollback1.out $message >>& check_error_rollback1.outx
end
echo ">> Move core file (from FATAL YDB-F-MEMORY) to avoid test framework from treating this as a test failure"
# Check if there are non-GT.M cores and if so move them out of the way for the next stage of the test
set nonomatch; set cores=(core*); unset nonomatch
if ("$cores" != "core*") then
	@ num = 1
	foreach corefile (core*)
		mv $corefile rollback1_core_${num}
		@ num++
	end
endif
echo ">>> Attempt journal switch in each region individually. Should be disallowed on ALL regions"
$MUPIP set -journal="enable,on,before" -reg AREG
$MUPIP set -journal="enable,on,before" -reg BREG
$MUPIP set -journal="enable,on,before" -reg DEFAULT

echo ">>> Induce out-of-memory error in second rollback by setting vmemoryuse to same value"
(limit vmemoryuse $mid; $gtm_tst/com/mupip_rollback.csh "" -back -verbose -resync=1 "*" >& rollback2.out)
$gtm_tst/com/backup_dbjnl.csh bak2 "*.gld *.repl *.dat *.mjl*" cp nozip # Dont use "mv". Want next rollback to use this db/jnl

echo ">>> Verify out-of-memory error in second rollback (logfile = rollback2.out)"
$gtm_tst/com/check_error_exist.csh rollback2.out "$oompattern" >>& check_error_rollback2.outx
# It is possible we optionally see "SYSTEM-E-ENO12", "YDB-E-MUNOACTION" and/or "SYSTEM-E-ENO11" messages
# along with the "YDB-F-MEMORY message. If so filter those out as well to avoid the test framework from catching them.
foreach message ("YDB-E-MUNOACTION" "SYSTEM-E-ENO12" "SYSTEM-E-ENO11")
	$gtm_tst/com/check_error_exist.csh rollback2.out $message >>& check_error_rollback2.outx
end
echo ">> Move core file (from FATAL YDB-F-MEMORY) to avoid test framework from treating this as a test failure"
# Check if there are non-GT.M cores and if so move them out of the way for the next stage of the test
set nonomatch; set cores=(core*); unset nonomatch
if ("$cores" != "core*") then
	@ num = 1
	foreach corefile (core*)
		mv $corefile rollback2_core_${num}
		@ num++
	end
endif

echo ">>> Attempt third (and final) rollback without any YDB-F-MEMORY error. This should work fine"
$gtm_tst/com/mupip_rollback.csh "" -back -verbose "*" >& rollback3.out

echo ">>> Verify third rollback ran fine (logfile = rollback3.out)"
$grep JNLSUCCESS rollback3.out

$gtm_tst/com/dbcheck.csh
