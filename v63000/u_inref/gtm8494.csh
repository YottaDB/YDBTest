#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_spanreg 0	# This test requires all the updates to go to DEFAULT region
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh . 2
$MSR START INST1 INST2 RP

# Note: There is no meaningful output in the reference file

# Start the primary script, that simply stops and starts source server to generate multiple history records
# The primary script signals end of test if it start-stops 50 times
# The secondary script signals end of test either after 60 seconds or after 15 backups, whichever is earlier
# The entire test stops whichever side finishes sooner
echo "# Start gtm8494_pri.csh in the background"
($gtm_tst/$tst/u_inref/gtm8494_pri.csh >&! pri.out & ; echo $!) >&! bg_pri.out

# Start the secondary script that does mupip backup -replinst in a loop until the primary times out
# It checks if the history records of primary and secondary are identical and prints an ERROR (BACKUP-E-HISTORY)
# if they are not identical and signals end of test (for primary to stop too)
# We do not expect to see the above BACKUP-E-HISTORY in the secondary log (which would be caught by the error catching mechanism)
echo "# Start gtm8494_sec.csh"
$MSR RUN RCV=INST2 SRC=INST1 '$gtm_tst/$tst/u_inref/gtm8494_sec.csh >&! sec.out'

echo "# wait for gtm8494_pri.csh to exit"
set pri_job = `$tail -1 bg_pri.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pri_job
$gtm_tst/com/dbcheck.csh
