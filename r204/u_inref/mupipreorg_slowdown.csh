#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# [multiplier] is the largest allowed ratio of the instructions MUPIP REORG -UPGRADE executes for 80000 nodes to those
# for 10000 nodes. That ratio was measured at 59x to 85x without the YDB@a25c628b fix and at no more than 18x with it,
# for both BG and MM, so the limit is drawn in between.
set multiplier = 30
echo "#--------------------------------------------------------------------------------------------------------------"
echo "# Test MUPIP REORG -UPGRADE instructions do not increase more than ${multiplier}x as the number of database nodes increases 8x"
echo "#"
echo "# For original issue, see:            https://gitlab.com/YottaDB/DB/YDBTest/-/work_items/803#note_2903069340"
echo "# For source of below test case, see: https://gitlab.com/YottaDB/DB/YDBTest/-/work_items/803#note_3151504040"
echo "# See also:                           https://gitlab.com/YottaDB/DB/YDBTest/-/work_items/803#note_3151620273"
echo "#--------------------------------------------------------------------------------------------------------------"
echo

setenv gtm_test_use_V6_DBs 0    # Disable V6 mode DBs as this test already switches versions for its various test cases
unsetenv gtm_poollimit
echo "# Choose a random V6 prior version"
$gtm_tst/com/random_ver.csh -type V6 >&! prior_ver.txt
if (0 != $status) then
	echo "TEST-E-FAIL, No prior versions available."
	break
else
	set prior_ver = `cat prior_ver.txt`
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

echo y > yes.txt
set block_size="-block_size=512"
set qualifiers = "$block_size -global_buffer_count=16384 -record_size=16128 -key_size=255"
set prev = 0
set scale = "0000"
foreach factor (1 2 4 8)
	echo
	set count = "${factor}${scale}"
	set tnum = "T${count}"

	echo "## ${tnum}: Test node count of $count"
	echo "# Switch to prior version $prior_ver"
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image

	echo "# Create a database with $block_size"
	setenv gtmgbldir ${tnum}.gld
	$gtm_tst/com/dbcreate.csh $tnum $qualifiers >&! ${tnum}-dbcreate.out
	$gtm_dist/mumps -run GDE exit >&! ${tnum}-gde.out
	echo '# Run [$gtm_dist/mumps -run %XCMD '"'for i=1:1:'$count' set ^gntp(0,"'$j(i,220))=$j(i,700)'"']"
	$gtm_dist/mumps -run %XCMD 'for i=1:1:'$count' set ^gntp(0,$j(i,220))=$j(i,700)'

	echo "# Switch to back to version $tst_ver"
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	$gtm_dist/mumps -run GDE exit >&! ${tnum}-gde.out
	echo '# Run [$gtm_dist/mupip upgrade -reg DEFAULT < yes.txt]'
	$gtm_dist/mupip upgrade -reg DEFAULT < yes.txt  >&! ${tnum}-upgrade.out
	echo '# Run [perf stat $gtm_dist/mupip reorg -upgrade -reg DEFAULT < yes.txt]'
	$gtm_tst/com/perfstat.csh $gtm_dist/mupip reorg -upgrade -reg DEFAULT < yes.txt >& ${tnum}-reorg.out
	# perf stat $gtm_dist/mupip reorg -upgrade -reg DEFAULT < yes.txt >&! ${tnum}-reorg.out
	$tst_awk -f $gtm_tst/com/perfstat_count.awk ${tnum}-reorg.out >! ${tnum}-instructions.out
end
echo

echo "# Confirm that the number of instructions does not increase more than ${multiplier}x from 1${scale} to 8${scale} nodes"
echo "# YottaDB commits prior to a25c628b (i.e. commit 8d898f25 and earlier) show instruction increases ranging from 59x to 85x."
set first_count = `cat T1${scale}-instructions.out`
set last_count = `cat T8${scale}-instructions.out`
if (("" != "$first_count") && ("" != "$last_count")) then
	echo "scale=2; `echo $last_count` / `echo $first_count`" | bc >&! changed.out
	set changed = `cat changed.out`
	echo "$changed <= $multiplier" | bc -l >&! results.out
	if (0 == `cat results.out`) then
		echo "TEST-E-FAIL, The number of instructions executed by MUPIP REORG -UPGRADE increased ${changed}x, more than ${multiplier}x, from 1${scale} to 8${scale} nodes (1${scale} nodes: $first_count vs. 8${scale} nodes: $last_count)"
	else
		echo "PASS, MUPIP REORG -UPGRADE instructions increased less than ${multiplier}x from 1${scale} to 8${scale} nodes"
	endif
endif
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
