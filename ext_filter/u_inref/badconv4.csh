#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv gtm_test_updhelpers 0	# Helpers cause error from rf_sync, so disable them.
echo "External Filter test with second mini-transaction changed into a dummy wrapped transaction with 2 sets"
setenv gtm_tst_ext_filter_rcvr \""$gtm_exe/mumps -run ^badconv4"\"

# Set white-box variables to avoid assert failures in source/receiver server due to external filter errors
# which this test induces.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 103

$gtm_tst/com/dbcreate.csh mumps 1
setenv rcvrlogfile $SEC_SIDE/RCVR_*.log
setenv startout $SEC_SIDE/START_*.out

# Get the receiver server pid
setenv pidrcvr `$tst_awk '/Receiver server is alive/ {print $2}' $startout`

# Do the updates that would cause the FILTERBADCONV error in the receiver server log due to the second one
# being changed into a dummy wrapped transaction with 2 sets
$GTM << EOF
set ^abc=1234
EOF

# Do RF_sync to make sure first update gets into the database before the error is caused by the next update
$gtm_tst/com/RF_sync.csh

$GTM << EOF
set ^def=3456
EOF

# Wait for the FILTERBADCONV error to first appear in the receiver log.
$gtm_tst/com/wait_for_log.csh -log $rcvrlogfile -message "FILTERBADCONV" -duration 300

# By this time, we expect the receiver server to have shutdown.
$gtm_tst/com/wait_for_proc_to_die.csh $pidrcvr 300
if ($status) then
	echo "TEST-E-RCVRALIVE, receiver server with pid=$pidrcvr is still alive. Verify if FILTERBADCONV error was seen above"
endif

# Print the FILTERBADCONV error messages
$gtm_tst/com/check_error_exist.csh $rcvrlogfile FILTERBADCONV

#
echo "Expect DATABASE EXTRACT to fail due to receiver dying"
$gtm_tst/com/dbcheck.csh -extract

echo
echo "Globals on secondary after badconv4:"
cat sec*.glo
