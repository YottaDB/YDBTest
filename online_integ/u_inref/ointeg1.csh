#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This subtest tests basic online integ functionality. A db is created, updates are made,
# an online integ is started with a white box test that will hold until the database
# has an error introduced (DBTNTOOLG) by changing the current TN in the file header.
# The online integ is then allowed to continue. Since the online integ started before
# the file header was updated, it will not see the errors. The integ is then run again
# so the error is shown

# This white box test case will hold the online integ until signalled via the test sequence field in nl.

setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 26
setenv gtm_white_box_test_case_count 1

#Go with dbg image since we are using a whitebox test
source $gtm_tst/com/switch_gtm_version.csh $tst_ver "dbg"

$gtm_tst/com/dbcreate.csh mumps 1

$GTM << EOF
set ^a=3
set ^b=5
h
EOF

$echoline
echo "# Kick off online integ in the background and have it wait once the snapshot is started."
$echoline
($MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! online_integ1.out & ; echo $! >! mupip1_pid.log) >&! bg_online_integ.out
set mupip1_pid = `cat mupip1_pid.log`

$gtm_tst/com/waitforOLIstart.csh

$echoline
echo "# Now that the snapshot is started, create a bunch of DBTNTOOLG errors."
$echoline
# Save the current TN so we can restore it later.
$DSE dump -file |& $grep 'Current transaction' | cut -c 26-44 > curr_tn.out
$DSE change -file -curr=1 >&! dse_change_file.out

$echoline
echo "# Signal the online integ to proceed"
$echoline
$DSE cache -change -offset=$hexoffset -size=4 -value=2 >&! dse_change_offset.out

$echoline
echo "# Wait for background online integ to complete"
$echoline
$gtm_tst/com/wait_for_proc_to_die.csh $mupip1_pid 120 >&! wait_for_OLI_die.out
if ($status) then
	echo "# `date` TEST-E-TIMEOUT waited 120 seconds for online integ process $mupip1_pid to complete."
	echo "# Exiting the test."
	exit
endif

$echoline
echo "# Verify no errors from online integ."
$echoline
$gtm_tst/com/grepfile.csh "No errors detected" online_integ1.out 1

$echoline
echo "# Now run online integ again."
$echoline
# Don't wait this time
unsetenv gtm_white_box_test_case_enable
# There will be different error report for regular and fast integ output, in which DBTNTOOLG will be the common one
$MUPIP integ $FASTINTEG -online -preserve -r DEFAULT >&! online_integ2.outx

$echoline
echo "# Verify DBTNTOOLG errors are present."
$echoline
$gtm_tst/com/grepfile.csh DBTNTOOLG online_integ2.outx 1
$gtm_tst/com/grepfile.csh INTEGERRS online_integ2.outx 1
$gtm_tst/com/backup_dbjnl.csh backup '*.dat'
$DSE change -file -curr=`cat curr_tn.out` >&! dse_restore_curr_tn.out
$gtm_tst/com/dbcheck.csh
