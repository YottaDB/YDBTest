#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
setenv test_reorg NON_REORG
setenv gtm_test_mupip_set_version "V5"
setenv gtm_test_spanreg 0 	# The calculated number of sets below doesn't work (reorg -truncate) with spanningregions
#Go with dbg image since we are using a whitebox test
$gtm_tst/com/dbcreate.csh mumps 3 -block_size=1024	# The truncate tests below are sensitive to block layout
$GDE << EOF
add -name c* -region=breg
add -name C* -region=breg
EOF

#If there are no global variables, REORG (and consequently TRUNCATE) will do nothing
$GTM << EOF
f i=1:1:18400 s ^a(i)=\$j(i,20)
f i=1:1:18400 s ^b(i)=\$j(i,20)
h
EOF

$MUPIP reorg -truncate >&! initial_truncate.outx
if ($status) then
	cat initial_truncate.outx
        echo "TEST failed in MUPIP reorg -truncate"
	exit 1
else
	$grep "Truncated" initial_truncate.outx
endif

# On all 5 of the shared memory intact crashes, MUPIP RUNDOWN will invoke wcs_recover, which will finish the truncate.
# However, on the first (55) shared memory deleted crash, recover_truncate will not finish the truncate because
# the fileheader had not yet been flushed to disk, so the next call of MUPIP REORG -TRUNCATE will truncate AREG.
echo ""
echo "#----- Begin WHITE_BOX tests (shared memory intact) -----#"
foreach wbnum (55 56 57 58 59)
	echo "# Enable WHITE BOX TESTING for WBTEST_CRASH_TRUNCATE_"{$wbnum-54}
	#set newblks = 32768
	$MUPIP extend -b=3000 AREG >&! extend_areg_intact_{$wbnum}.out
	$MUPIP extend -b=3000 BREG >&! extend_breg_intact_{$wbnum}.out
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number $wbnum
	setenv gtm_white_box_test_case_count 1

	echo "Truncate gets killed now"
	$MUPIP reorg -truncate >&! trunc_wbtest_intact_{$wbnum}_1.outx
	$grep "TRUNC" trunc_wbtest_intact_{$wbnum}_1.outx
	$grep "Truncated" trunc_wbtest_intact_{$wbnum}_1.outx
	unsetenv gtm_white_box_test_case_enable
	#Next process to grab crit should invoke wcs_recover() --> recover_truncate()

	$MUPIP rundown -reg "*" >&! trunc_wbtest_intact_rundown_{$wbnum}.outx
	$MUPIP rundown -relinkctl >&! trunc_wbtest_intact_rundown_ctl_{$wbnum}.outx

	$MUPIP reorg -truncate >&! trunc_wbtest_{$wbnum}_2.outx
	if ($status) then
		cat trunc_wbtest_{$wbnum}_2.outx
	        echo "TEST failed in MUPIP reorg -truncate"
		exit 1
	else
		$grep "TRUNC" trunc_wbtest_{$wbnum}_2.outx
		$grep "Truncated" trunc_wbtest_{$wbnum}_2.outx
	endif

	$gtm_tst/com/dbcheck.csh
end
#------ End WHITE_BOX tests ------#

echo ""
echo "#----- Begin WHITE_BOX tests (shared memory deleted) -----#"
#After kill, delete shared memory with ipcrm.
foreach wbnum (55 56 57 58 59)
	echo "# Enable WHITE BOX TESTING for WBTEST_CRASH_TRUNCATE_"{$wbnum-54}
	#set newblks = 32768
	$MUPIP extend -b=3000 AREG >&! extend_areg_{$wbnum}.out
	$MUPIP extend -b=3000 BREG >&! extend_breg_{$wbnum}.out
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number $wbnum
	setenv gtm_white_box_test_case_count 1

	echo "Truncate gets killed now"
	($MUPIP reorg -truncate >&! trunc_wbtest_{$wbnum}_1.outx & ; echo $! >&! trunc_pid.log) >&! exec.out
	set pid = `cat trunc_pid.log`

	# Wait for killed truncate process to die. If it hasn't died by the time ipcrm is called (which can happen on the slower
	# boxes, ipcrm will not delete shared memory since it will see that a process is still attached. Then when MUPIP RUNDOWN
	# invokes grab_crit, it will complete the truncate as in the 'shared memory intact' case.
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 20

	$grep "TRUNC" trunc_wbtest_{$wbnum}_1.outx
	$grep "Truncated" trunc_wbtest_{$wbnum}_1.outx
	unsetenv gtm_white_box_test_case_enable
	echo "Deleting shared memory"
	#Get the shared memory id
	set shmid = `$MUPIP ftok a.dat |& $grep 'a\.dat' | $tst_awk '{print $6}'`
	#Delete shared memory
	$gtm_tst/com/ipcrm -m $shmid

	$MUPIP rundown -reg "*" >&! trunc_wbtest_deleted_rundown_{$wbnum}.outx
	$MUPIP rundown -relinkctl >&! trunc_wbtest_deleted_rundown_ctl_{$wbnum}.outx
	#Next process should invoke db_init() --> recover_truncate()

	$MUPIP reorg -truncate >&! trunc_wbtest_{$wbnum}_2.outx
	if ($status) then
		cat trunc_wbtest_{$wbnum}_2.outx
	        echo "TEST failed in MUPIP reorg -truncate"
		exit 1
	else
		$grep "TRUNC" trunc_wbtest_{$wbnum}_2.outx
		$grep "Truncated" trunc_wbtest_{$wbnum}_2.outx
	endif

	$gtm_tst/com/dbcheck.csh
end
#------ End WHITE_BOX tests ------#
