#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# This test (v63014/gtm9332) uses a white box test to verify that locks are behaving in a predictable
# fashion when the released-lock-count rolls over. Previously, people could apparently be notified of
# a successful lock acquire that they did not actually own.
#
# The white box test resets pctl->ctl->wakeups to one of two different values when mlk_wake_pending()
# is entered - If the value is less than 0xffffffff, the value is set to 0xffffffff but if it is higher,
# the value is set to 0xffffffffffffffff, the highest possible value before it rolls over to 0 on its
# next increment. Because of this, we let the test loop 3 times to make sure we reach that point in
# one of the two worker processes.
#
# Once at that point, we run LKE to show who holds the lock and report an error if it is not us or if
# the lock is not held at all.
#
# This test has been confirmed to fail on V63014 with GTM9332 reverted and with the assert(retval) at
# the top of mlk_lock() modified to allow the WBTEST_LCKWAKEOVRFLO white box test bypass the assert
# failure that would otherwise happen. This allows this test to continue and get to the broken lock
# demonstration.
#
echo '# Running v63014/gtm9332 - Test rollover of lock wakeups counter using white-box test case. Prior to'
echo '# V63014, this condition could leave a process thinking that it got a lock when it did not. So we grab'
echo '# a lock and release it 3 times each time verifying with a call to LKE that we actually got the lock.'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Enable white box test used in this test (WBTEST_LCKWAKEOVRFLO == 171)'
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 171	# WBTEST_LCKWAKEOVRFLO - set lock wakeups to just shy of overflo
setenv gtm_white_box_test_case_count 1
echo
echo '# Drive gtm9332 test routine'
$gtm_dist/mumps -run gtm9332
echo
echo '# grep for pass/fail messages from generated log files (*.mjo)'
grep -E "Worker|FAIL|PASS" gtm9332_{1,2}.mjo
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
