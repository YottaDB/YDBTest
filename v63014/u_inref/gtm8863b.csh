#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
echo '# gtm8863b - This is a test of the so called "toggle type statistics".'
echo '#'
echo '# These are statistics that only ever have a value of 0 or 1 indicating a situation in-progress.'
echo '# When looking at the global statistics, the values seen are the sum of the toggle events. This'
echo "# test's validation is done by returning all the toggle statistics every 3 seconds for a 15"
echo '# second duration and looking at each line verifying two things:'
echo '#  1. Each toggle value does not exceed the number of worker-processes running.'
echo '#  2. For each of the monitored toggle switches, a non-zero value is shown at least once.'

#setenv acc_meth "BG" 	 	  # MM does not allow the before image journaling we use in this test
#setenv gtm_test_jnl SETJNL	  # We want this DB to be journaled
#setenv tst_jnl_str -journal=enable,on,before

echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
echo '# Enable stat sharing'
$MUPIP set -stats -region "*"
echo
echo '# Drive gtm8863b test routine'
$gtm_dist/mumps -run gtm8863b
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
