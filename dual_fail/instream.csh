#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright 2002, 2014 Fidelity Information Services, Inc	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
if (0 != $test_replic_mh_type) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif
source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # subtests in this test do a failover and so disable -trigupdate

# subtests in this test do a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
#
# Large align size will have issues with 32 bit OS and the maximum align sizes vary across the GG servers
# So force the align_size to the testsystem default value i.e 4096.
setenv test_align 4096
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/align=[1-9][0-9]*/align='$test_align'/'`
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
# Following is to work around C9D07-002359 for debug versions
##DISABLED_TEST##REENABLE##
setenv tst_jnl_str "$tst_jnl_str,epoch=300"
##END_DISABLE##
echo "DUAL_FAIL test Starts..."
setenv gtm_test_dbfill "IMPTP"
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
if ($LFE == "E") then
	setenv test_sleep_sec 45
	setenv test_sleep_sec_short 10
	setenv test_tn_count 10000
	setenv test_tn_count_short 1000
	setenv gtm_test_jobcnt 5
else
	setenv test_sleep_sec 5
	setenv test_sleep_sec_short 5
	setenv test_tn_count 2000
	setenv test_tn_count_short 500
	setenv gtm_test_jobcnt 2
endif
# use a tst_buffsize of 8MB for all dual fail tests, per C9D06-002314
setenv tst_buffsize 8388608
setenv subtest_list "dual_fail1 dual_fail2 dual_fail3 dual_fail4 dual_fail4a dual_fail5 dual_fail6"

# all tests use the same for uniform and deterministic output. if spanning
# nodes testing is enabled, choose among some pre-defined testing values.
# There are 3 options. The record size is kept constant to avoid filling disks,
# but the block and key sizes are varied. The record size alone is not enough
# for IMPTP to create records that span blocks. Key size is chosen to fit
# within the block limits and force spanning nodes.
setenv rand_args "125 1050 4096"
if ($?gtm_test_spannode) then
	if ($gtm_test_spannode > 0) then
		#  1019,1050,4096 - no spanning nodes testing, but raise the key size
		#  325,1050,512   - spanning nodes testing because the max record does not fit in a block
		#  825,1050,1024  - spanning nodes testing because the max record and key size forces the spanning
		setenv rand_args `$gtm_exe/mumps -run chooseamong 1019,1050,4096 325,1050,512 825,1050,1024`
	endif
endif
setenv rand_args "${rand_args:as/,/ /}"

$gtm_tst/com/submit_subtest.csh
echo "DUAL_FAIL test DONE."
