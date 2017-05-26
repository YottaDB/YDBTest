#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-8332 Journal files can have out-of-order timestamps even if system time does not go back

# Journaling is turned on explicitly in this test. So let's not randomly enable it in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL

echo "Create 2 regions AREG and DEFAULT with ^a* mapping to AREG and everything else to DEFAULT"
setenv gtm_test_spanreg 0		# Test requires traditional global mappings, so disable spanning regions
$gtm_tst/com/dbcreate.csh mumps 2

echo "Enable journaling on AREG. Do not enable it on DEFAULT as we dont want 2-second sleeps there for every update"
$MUPIP set $tst_jnl_str -reg AREG >& mupip_set1.out

echo "Start GT.M process to do update to journaled region. This will sleep for 2 seconds before doing the update"
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 119
$gtm_dist/mumps -run start^gtm8332
unsetenv gtm_white_box_test_case_enable

echo "sleep 1 second to make it more likely MUPIP SET JOURNAL timestamp in new journal file is 1 second more than GT.M process"
sleep 1

echo "Switch journal file. It is very likely this switch happens BEFORE the GT.M process finishes its 2 second sleep and update"
$MUPIP set $tst_jnl_str -reg AREG >& mupip_set2.out

echo "Wait for GT.M process to quit before exiting the test"
$gtm_dist/mumps -run stop^gtm8332

echo "Extract journal files and verify <time> never decreases"
$gtm_tst/com/jnlextall.csh a
cat a.mjf_* a.mjf | $gtm_exe/mumps -run timecheck^gtm8332

$gtm_tst/com/dbcheck.csh
