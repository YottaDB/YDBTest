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
echo
echo '# GTM-9329 - verify two subissues for this issue:'
echo '#   1. Disabling the current (expired) timeout from within the timeout code works properly - previously to loop (dbg only)'
echo '#   2. Trying to assign an invalid code vector should not replace the current working vector - previously left blank'
if ("dbg" == "$tst_image") then
    setenv gtm_white_box_test_case_enable 1
    setenv gtm_white_box_test_case_number 170	# Enable white box test WBTEST_ZTIM_EDGE
    echo
    echo '# Drive subissue1^gtm9329 test routine for 1st subissue'
    $gtm_dist/mumps -run subissue1^gtm9329
    unsetenv gtm_white_box_test_case_enable
    unsetenv gtm_white_box_test_case_number
endif
echo
echo '# Drive subissue2^gtm9329 test routine for 2nd subissue'
$gtm_dist/mumps -run subissue2^gtm9329
#
# The end - no database used.
