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

echo '# Test for GTM-9328 - Verify that $ZINTERRUPT cannot be invoked in a nested fashion (discussion can be found'
echo '# here: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/482#note_1169440807)'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run ^%XCMD 'set ^ready=0'	# Initialize to not-ready state
echo
echo '# Start up main routine in the background'
$gtm_dist/mumps -run gtm9328^gtm9328&
echo
echo '# Start invoking routines to pelt our main routine with $ZINTERRUPT signals to drive its'
echo '# $ZINTERRUPT handler. If these succeed without assert failure (which will be caught by'
echo '# the test framework if any), we can consider the test a success.'
repeat 100 $gtm_dist/mumps -run intrpt^gtm9328
echo
echo "# Shutdown the main routine if it hasn't already shut itself down and wait for it to die"
set testpid=`$gtm_dist/mumps -run ^%XCMD 'set ^done=1 write ^pid,!'`
$gtm_tst/com/wait_for_proc_to_die.csh $testpid 300
echo
echo '# Verify database'
$gtm_tst/com/dbcheck.csh
