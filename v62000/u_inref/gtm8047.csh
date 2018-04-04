#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
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
#
# GTM-8047 [nars] YDB-E-MEMORY errors during non-mandatory stringpool expansion result in no garbage collection
#
# GTM-8047 had two issues.
#
# a) A dbg issue where an assert in UNWIND macro (invoked from stp_gcol_ch) was
#    tripping. This is fixed using the ok_to_UNWIND_in_exit_handling variable. The below test case verifies this fix.
#    Note that the v53002/C9D12002471 test exercised this failure scenario but it does so very rarely and so we
#    create this separate test to exercise just that failure more frequently.
#
# b) A pro issue where invoking stp_gcol in exit handling (while creating a fatal zshow dump file) could end up
#    in no garbage collection taking place but returning success from stp_gcol with a faulty indication that
#    the entire stringpool is available for use which means the caller could potentially overwrite/corrupt mvals.
#    A test case to create this scenario (prove corruption happens) is non-trivial to create. So not spending time
#    on this part.

# Disable autorelink for this test because of virtual memory limitations.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Prevent core dump files from being created due to YDB-E-MEMORY fatal errors
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 102

# If gtmdbglvl had been set, reset it unconditionally since otherwise we will be doing malloc storage chain verification
# for EVERY malloc/free. This test does a LOT of mallocs until the virtual memory limit is exceeded so the GT.M process
# will be burning lots and lots of CPU time doing only verifications before it reaches the memory limit. This causes the
# test to run for hours. To avoid this situation, we turn off gtmdbglvl checking for this particular subtest.
unsetenv gtmdbglvl

# to avoid NONUTF8LOCALE errors when running the M script below switch to M mode always.
# Any case chset does not matter to this test
$switch_chset M >& switch_chset.out

# The test fills up the stringpool first and then creates a YDB-E-MEMORY error which in turn would create a zshow
# fatal dump file that would end up doing stp_gcol. This is Issue (a) described above.

$gtm_tst/com/dbcreate.csh mumps 1 -block_size=2048 -record_size=4096 -key_size=1010

if !(("hp-ux" == "$gtm_test_osname") || ("aix" == "$gtm_test_osname")) then
	# Linux kernels seem to kill processes that eat up a lot of virtual memory. This has been observed at least in scylla.
	# To overcome that problem, we invoke setrlimit() system function via an external call to limit our virtual memory quota
	# and then run the M program. The reason we do not use the shell built-in 'limit vmemoryuse' is because it affects the
	# tcsh process itself, occasionally causing it to core. The limit chosen randomly and is exercised on Linux and SunOS
	# boxes.
	source $gtm_tst/com/cre_xcall_utils.csh

	if !($?gtm_test_replay) then
		setenv gtm_test_vlimit `$gtm_exe/mumps -run %XCMD 'write 1000*(40+$random(70))'`
		echo "# Randomly chosen virtual memory limit:"		>>&! settings.csh
		echo "setenv gtm_test_vlimit $gtm_test_vlimit"		>>&! settings.csh
	endif

	$gtm_exe/mumps -run gtm8047 >& gtm8047.outx

	# The test will create YDB_FATAL_* files in most cases but in some cases it might not. So filter that out.
	mv -f YDB_FATAL* filter.ZSHOW_DMP >& mv.out

	# Test that GTM-F-MEMORY error does show up somewhere (either in zshow dump file or in output)
	# Note that sometimes GT.M could end up with memory issues even while loading encryption libraries or so
	# and therefore we might not always see GTM-F-MEMORY but we are more likely to see SYSTEM-E-ENO12. So check that.
	# Also we have found some situations where loading the encryption library does not print the ENO12 error. In
	# that case it prints a "Cannot allocate memory" error so include that in the search.
	# Update: In some cases we do not see either of the above two search strings. But we do see 150373340, in $ZSTATUS.
	# This corresponds to ERR_MEMORY. So add that also to the search string.
	# Update2: In other cases we do not see any of the existing search strings but see CRYPTDLNOOPEN. So have added
	# this to the list.
	set searchstring = "SYSTEM-E-ENO12|Cannot allocate memory|150373340,|CRYPTDLNOOPEN"
	if (-e filter.ZSHOW_DMP) then
		$grep -E "$searchstring" filter.ZSHOW_DMP >& /dev/null
		set status1 = $status
		if ($status1) then
			# In some cases, it is possible we dont even see a $ZSTATUS in the zshow dump file.
			# This is because the zshow dumping stopped prematurely due to nested memory errors.
			# This is a known issue in GT.M even after GTM-5238 (C9D12-002471).
			# Treat this case as a YDB-E-MEMORY error (i.e. success).
			$grep '^$ZSTATUS=' filter.ZSHOW_DMP >& /dev/null
			set status2 = $status
			if ($status2) then
				set status1 = 0
			endif
		endif
	else
		set status1 = 1
	endif
	$grep -E "$searchstring" gtm8047.outx >& /dev/null
	set status2 = $status
	if ((0 != $status1) && (0 != $status2)) then
		echo "$searchstring not found in either filter.ZSHOW_DMP or gtm8047.outx. Test FAIL"
		echo "cat gtm8047.outx"
		cat gtm8047.outx
		if (-e filter.ZSHOW_DMP) then
			$grep '$ZSTATUS' filter.ZSHOW_DMP
		endif
	endif
endif

$gtm_tst/com/dbcheck.csh
