#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# * Enable freeze-on-error with sample custom errors
# * Start source and receiver
# * Start work
# * Stop receiver
# * Wait for new journal files
# * Stop work and source, removing journal pool
# * Remove old journal files
# * Start source
# * Start receiver
#
# Before fix, result would be JNLFILOPN from source, and frozen instance.
# After fix, result is JNLFILRDOPN fron source, and no instance freeze.

# Frozen instance puts garbage in checkhealth output, so disable Fake ENOSPC.
setenv		gtm_test_fake_enospc	0

if ($gtm_test_jnl_nobefore) then
	# nobefore image randomly chosen
	set b4nob4image = "nobefore"
else
	# before image randomly chosen
	set b4nob4image = "before"
endif

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 1

unsetenv	gtm_custom_errors

$MUPIP set -inst -region "*"
$MUPIP set -journal=enable,$b4nob4image,alloc=2048,auto=16584,extension=16384 -region "*"

setenv		gtm_custom_errors	$gtm_tools/custom_errors_sample.txt

$MSR START INST1 INST2

# Add transaction
$gtm_dist/mumps -run %XCMD "set ^a=1"

$MSR SYNC INST1 INST2
$MSR STOPRCV INST1 INST2

# Switch to new journal file
$MUPIP set -journal=enable,$b4nob4image -region "*"

# Add transaction
$gtm_dist/mumps -run %XCMD "set ^a=2"

# Switch to new journal file
$MUPIP set -journal=enable,$b4nob4image -region "*"

# Stop source to remove journal pool
$MSR STOPSRC INST1 INST2

# Remove old journal files
ls -ltr mumps.mjl* >&! journal_files_before.out ; rm mumps.mjl_* ; ls -ltr mumps.mjl* >&! journal_files_after.out

$MSR STARTSRC INST1 INST2
get_msrtime

# Get the source server pid
$MUPIP replic -source -checkhealth >& checkhealth.out
set srcpid=`sed -n 's/.*source server pid \[\([0-9][0-9]*\)\].*/\1/p' < checkhealth.out`

# Without the fix, this will cause the source instance to freeze.
# With the fix, the source server will exit with a JNLFILRDOPN error.
$MSR STARTRCV INST1 INST2

$gtm_tst/com/wait_for_proc_to_die.csh $srcpid 120
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message JNLFILRDOPN -duration 120 -waitcreation
$gtm_tst/com/wait_for_log.csh -log SRC_$time_msr.log -message ENO2 -duration 120 -waitcreation
$msr_err_chk SRC_$time_msr.log JNLFILRDOPN ENO2

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do leftover ipc rundown if needed before doing rundown in test
# Clean up after the dead source server and refresh the links
$MUPIP rundown -region "*" >&! rundown.out
$MSR REFRESHLINK INST1 INST2

$MSR STOPRCV INST1 INST2

$gtm_tst/com/dbcheck.csh -noshut
