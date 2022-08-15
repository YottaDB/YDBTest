#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo '# Test for for various database updates via commands while a FREEZE -ONLINE is in effect. This test'
echo '# covers the (similar) issues in both gtm8772 and gtm8784. This is also a test for GTM-9308 as this'
echo '# test does not run correctly without it.'
echo

setenv acc_meth BG			# Some of the MUPIP commands we will be using don't work with MM databases so avoid them
setenv gtm_test_jnl "SETJNL"		# Enable journaling when DB is created
unsetenv gtm_db_counter_sem_incr	# When this value is randomly set to 16384, this causes a counter semaphore
	 				# overflow when 2 processes access the database concurrently which then prevents
					# DB open/close related actions from doing doing database rundown (and in turn
					# file-header flushes) leaving just one pwrite64() call instead of the 4 calls
					# we expect to get. So unset this envvar so we get consistent results.
setenv gtm_test_mupip_set_version "disable"     # ASYNCIO and V4 format don't go together. So, disable creating V4 formats

echo '## Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo
echo '## Drive the gtm8772ANDgtm8784 routine to try different commands when MUPIP CANNOT get standalone mode and is FROZEN'
$gtm_dist/mumps -run MupipSetNonStandaloneFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Drive the gtm8772ANDgtm8784 routine to try different commands when MUPIP CAN get standalone mode and is FROZEN'
$gtm_dist/mumps -run MupipSetStandaloneFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Drive the gtm8772ANDgtm8784 routine to try different commands when MUPIP CAN get standalone mode and is UNFROZEN'
$gtm_dist/mumps -run MupipSetStandaloneUnFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Drive the gtm8772ANDgtm8784 routine to try a MUPIP RUNDOWN command and is FROZEN'
$gtm_dist/mumps -run MupipRundownStandaloneFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Drive the gtm8772ANDgtm8784 routine to try a MUPIP BACKUP command and is FROZEN'
$gtm_dist/mumps -run MupipBackupStandaloneFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Check that certain MUPIP SET commands flush only the file header by checking straces of the runs while UNFROZEN'
$gtm_dist/mumps -run MupipSetFileHeaderFlushUnFrozen^gtm8772ANDgtm8784
echo
echo
echo '## Validate DB'
$gtm_tst/com/dbcheck.csh
