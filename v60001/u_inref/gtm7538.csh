#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv		gtm_test_freeze_on_error	1
setenv		gtm_custom_errors		$gtm_tools/custom_errors_sample.txt
setenv		gtm_test_mupip_set_version	"disable"
unsetenv	gtm_test_fake_enospc

$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate.out

$MSR START INST1 INST2 RP
get_msrtime
set start_time=$time_msr

echo "#"
echo "# Start mumps in background"
echo "#"
# Keeping a mumps process prevents the source shutdown from removing the journal pool
set backslash_quote
unsetenv gtm_boolean		# to ensure short-circuiting else boolean conditional on zsystem below will give GVUNDEF
unsetenv gtm_side_effects	# also needed to ensure gtm_boolean does not get implicitly turned on
$gtm_exe/mumps -run %XCMD "s ^a=1  for i=1:1:300 zsystem:\$data(^b)&('\$\$^isprcalv(^b)) \"kill -9 \"_\$j  hang 1" >&! mumps_bg.out &	# BYPASSOK kill
unset backslash_quote
set bgpid=$!

# Make sure above got started
$gtm_exe/mumps -run %XCMD 'for i=1:1:120 halt:$data(^a)  hang 1' >&! mumps_wait.out

echo "#"
echo "# Stop source"
echo "#"
setenv gtm_test_other_bg_processes 1	# Signal SRC_SHUT to ignore shutdown error since another process is running in the background
$MSR STOPSRC INST1 INST2
unsetenv gtm_test_other_bg_processes

echo "#"
echo "# Stop mumps but make sure db shm is leftover"
echo "#"
# Tell background process to stop and wait for it to die
set backslash_quote
$gtm_exe/mumps -run %XCMD "s ^b=\$j" >&! mumps_stop.out
unset backslash_quote
$gtm_tst/com/wait_for_proc_to_die.csh $bgpid 120

echo "#"
echo "# Freeze"
echo "#"
$MUPIP replicate -source -freeze=on -nocomment |& tee freeze.out

echo "#"
echo "# Checkhealth on a frozen instance with no source server running and leftover db shm. Should not hang"
echo "#"
$MUPIP replicate -source -checkhealth

echo "# Run down db shm but temporarily unfreeze to let rundown do its job"
$MUPIP replicate -source -freeze=off -nocomment |& tee unfreeze.out
$MUPIP rundown -reg DEFAULT -override -cleanjnl	>& rundown1.out # cleanup db shm
$MUPIP replicate -source -freeze=on -nocomment |& tee freeze2.out

echo "#"
echo "# Redo Checkhealth on a frozen instance with no source server running and no leftover db shm. This should hang"
echo "#"
# This should freeze, so do it in the background
$MUPIP replicate -source -checkhealth >&! health.out &
$gtm_tst/com/wait_for_log.csh -log health.out -message MUINSTFROZEN
set bgpid=$!

echo "#"
echo "# Unfreeze"
echo "#"
$MUPIP replicate -source -freeze=off -nocomment |& tee unfreeze2.out

$gtm_tst/com/wait_for_proc_to_die.csh $bgpid 120

echo "# Capture full checkhealth output"
cat health.out

echo "#"
echo "# Checkhealth on an unfrozen instance with no source server running"
echo "#"
$MUPIP replicate -source -checkhealth

source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do leftover ipc rundown if needed before doing rundown in test

echo "#"
echo "# Rundown"
echo "#"
$MUPIP rundown -region "*" -override >&! rundown2.out

$MSR STOPRCV INST1 INST2
$gtm_tst/com/dbcheck.csh
