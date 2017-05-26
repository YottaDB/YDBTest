#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test switching of INST1 -> INST3 -> INST4 to INST1 -> INST4 -> INST3
# The test randomizes a) Number of regions between 1 and 5 and b) Shut-restart all servers vs shut-start only INST3-INST4
# This is because without GTM-7721/GTM-7722 fixes, the test case would work for single region but not multi-region and also
# would work for shut-start all servers but would fail if only INST3-INST4 is shut-started
#
if !($?gtm_test_replay) then
	# Random number of regions
	set pqqp_regions = `$gtm_exe/mumps -run rand 5 1 1`
	# Randomly shut-start all or shut-start only INST3-INST4
	set pqqp_shutall = `$gtm_exe/mumps -run rand 2`
	# Random number of updates
	set pqqp_updates = `$gtm_exe/mumps -run rand 10 1 1`
	echo "setenv pqqp_regions $pqqp_regions"	>>&! settings.csh
	echo "setenv pqqp_shutall $pqqp_shutall"	>>&! settings.csh
	echo "setenv pqqp_updates $pqqp_updates"	>>&! settings.csh
endif
$MULTISITE_REPLIC_PREPARE 2 2

setenv gtm_test_sprgde_id "ID${pqqp_regions}"	# to create/use different .sprgde files based on # of regions
$gtm_tst/com/dbcreate.csh mumps $pqqp_regions 125 1000 1024 4096 1024 4096 >&! dbcreate_rand_regions.out

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

echo "# Some updates on INST1"
$gtm_exe/mumps -run %XCMD 'for i=1:1:'$pqqp_updates' set ^a(i)=i,^b(i)=i,^c(i)=i,^d(i)=i,^e(i)=i'

$MSR SYNC INST1 INST3
$MSR SYNC INST3 INST4

echo "# Randomy do one of the below two choices - Ouput of the respective MSR commands redirected to INST34_to_INST43.out to handle this randomness"
echo "#   A) STOP ALL_LINKS   ; START INST1 INST2 ; START INST4 INST3 ; START INST1 INST4"
echo "#   B) STOP INST1 INST3 ;  STOP INST3 INST4 ; START INST4 INST3 ; START INST1 INST4"

if ($pqqp_shutall) then
	$MSR STOP ALL_LINKS		>>&! INST34_to_INST43.out
	$MSR START INST1 INST2 RP	>>&! INST34_to_INST43.out
	$MSR START INST4 INST3 RP	>>&! INST34_to_INST43.out
	$MSR START INST1 INST4 RP	>>&! INST34_to_INST43.out
else
	$MSR STOP INST1 INST3		>>&! INST34_to_INST43.out
	$MSR STOP INST3 INST4		>>&! INST34_to_INST43.out
	$MSR START INST4 INST3 RP	>>&! INST34_to_INST43.out
	$MSR START INST1 INST4 RP	>>&! INST34_to_INST43.out
endif

echo "# Some more updates on INST1"
$gtm_exe/mumps -run %XCMD 'for i=1:1:'$pqqp_updates' set ^b(i)=i'

$gtm_tst/com/dbcheck.csh
