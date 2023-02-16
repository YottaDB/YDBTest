#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "DUAL_FAIL_EXTEND test Starts..."
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
#
setenv test_debug 1
# Following is to work around C9D07-002359 for debug versions
##DISABLED_TEST##REENABLE##
setenv tst_jnl_str "$tst_jnl_str,epoch=300"
##END_DISABLE##
setenv gtm_test_dbfill "IMPTP"
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
if ($LFE == "E") then
	# To work around C9E02-002514 we need to have test_sleep_sec more than 60 seconds.
	# Once C9E02-002514 is fixed go back to 30 second or 60 seconds
	setenv test_sleep_sec 90
	setenv test_short_sleep_sec 15
	setenv gtm_test_jobcnt 3
else
	setenv test_sleep_sec 30
	setenv test_short_sleep_sec 10
	setenv gtm_test_jobcnt 2
endif

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # subtests in this test do a failover and so disable -trigupdate

# subtests in this test do a failover. So A->P is not possible
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif

#
# use a tst_buffsize of 8MB for all dual fail tests, per C9D06-002314
setenv tst_buffsize 8388608
# Earlier all *_no_ipcrm_* subtests were disabled for HPUX due to below.
# The *_no_ipcrm* subtests use KILL -9 to crash GT.M processes and do not clean up shared memory thereby leaving it
# in an inconsistent state. GT.M on HPUX/HPPA implements various database latches using a microlock that takes a
# a few instructions to obtain and release. If a process gets shot by a kill -9 during that small window, there
# is no recovery logic currently built in it. Trying to do MUPIP RUNDOWN on that causes assert failures in aswp.c.
# See issue signature <C9H04_002844_Assert_fail_ASWP_line_68_on_HPUX> for more details. Fixing the HP microlock
# to have recovery logic built in is non-trivial. Hence disabling these subtests for now.
# Although a TR C9H04-002853 was created to address one issue that came out of the test failure,
# it was just the tip of the iceberg. The bigger issue is that we do not support kill -9s with NO_IPCRM.
# Therefore, all NO_IPCRM subtests must not be run as part of the automated test
# or they could give us repeated failures like the assert in jnl_write_attempt.c below.
# So disabling them on all Unix and moving to manually_start test.
# See <C9H04_002853_Assert_fail_jnl_write_attempt_line_205_JNLMEMDSK> for details
#setenv subtest_list "dual_fail2_no_ipcrm1 dual_fail2_no_ipcrm2 dual_fail3_nonsym dual_fail2_mu_stop dual_fail2_sig_quit"
setenv subtest_list "dual_fail2_mustop_sigquit"
$gtm_tst/com/submit_subtest.csh
echo "DUAL_FAIL_EXTEND test DONE."
