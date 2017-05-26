#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# this is not a multisite test, but it is easier this way
echo "External Filter test with a bad filter"
$MULTISITE_REPLIC_PREPARE 2
setenv gtm_tst_ext_filter_src \""$gtm_exe/mumps -run ^badconv"\"

# Set white-box variables to avoid assert failures in source/receiver server due to external filter errors
# which this test induces.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 103

$gtm_tst/com/dbcreate.csh mumps 1
$MSR START INST1 INST2

get_msrtime
setenv srclogfile SRC_${time_msr}.log
# Get the source server pid
setenv pidsrc `$tst_awk '/Source server is alive in ACTIVE mode/ {print $2}' START_${time_msr}.out`

# Do the update that would cause the FILTERBADCONV error in the source server log.
$GTM << EOF
s ^abc=1234
tstart
set ^def=3456
set ^ghi=7890
tcommit
EOF

# Wait for the FILTERBADCONV error to first appear in the source log. This way, we don't end up cleaning
# the IPCs before the FILTERBADCONV actually appears thereby causing REPLREQURUNDOWN errors.
# See <badconv_REPLREQRUNDOWN/resolution_v2.txt> for more details
$gtm_tst/com/wait_for_log.csh -log $srclogfile -message "FILTERBADCONV" -duration 300

# By this time, we expect the source server to have shutdown. By ensuring this is indeed the case, we can
# safely remove the IPCs below
$gtm_tst/com/wait_for_proc_to_die.csh $pidsrc 300
if ($status) then
	echo "TEST-E-SRCALIVE, source server with pid=$pidsrc is still alive. Verify if FILTERBADCONV error was seen above"
endif

# Shutdown the receiver servers
$MSR STOPRCV INST1 INST2
$MSR REFRESHLINK INST1 INST2
# Print the FILTERBADCONV error messages
$gtm_tst/com/check_error_exist.csh $srclogfile FILTERBADCONV

# The jnlpool ipcs are left-behind when the source dies. Let's clean those up here:
# A mupip rundown would take care of this cleaning up. Need to use -override to avoid MUUSERLBK errors
$MUPIP rundown -reg "*" -override >& rundown.log
#
$gtm_tst/com/dbcheck.csh
