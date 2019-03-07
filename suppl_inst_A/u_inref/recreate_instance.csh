#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ($?gtm_test_replay) then
	source $gtm_test_replay
endif

# If the platform/host does not have prior GT.M versions, disable first section of the test
if (! $?gtm_test_nopriorgtmver) then
	# Test that an instance file create by a previous GT.M version needs to be recreated before it can be used
	if (! $?gtm_test_replay) then
		set prior_ver = `$gtm_tst/com/random_ver.csh -gte V51000 -lt V55000`
		if ("${prior_ver}" =~ "*-E-*") then
			echo "No such prior version : ${prior_ver}"
			exit -1
		endif
		echo "setenv prior_ver ${prior_ver}"				>>&! settings.csh
	endif
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

	echo "# Switching to prior version"
	source $gtm_tst/com/switch_gtm_version.csh ${prior_ver} $tst_image
	echo "# Creating replication instance file using prior version"
	$MUPIP replicate -instance_create -name=INST1 $gtm_test_qdbrundown_parms
	echo "# Switching back to current version"
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	echo "# Creating global directory as source server startup requires it even if it is going to issue a REPLINSTFMT error"
	$GDE exit >& oldver_gde_create.out
	echo "# Start source server. Expect REPLINSTFMT error"
	$MUPIP replic -source -start -instsecondary=nobody -secondary=localhost:12345 -log=SRC.log

	# Just mumps.repl file would have been created. Rename it in case it is required for debugging later.
	mv mumps.repl mumps.repl_${prior_ver}
endif

# 48) Test of updateresync scenarios.
#         A->B replication happens. A is at seqno 100. B is at seqno 100. i.e. backlog is 0.
#         And then A crashes. Instead of bringing up B as primary, bring A up again as the primary.
#         But recreate the instance file on A. Now A is at 100 while B is at 100 but A has no history records.
#         So B has to use updateresync. Make sure B can successfully connect to A with -updateresync.
#         Do 100 more updates on A and verify that all the new 100 updates get replicated to B.
#         Note: A,B could be either non-supplementary or supplementary instances and the behavior is expected to be the same.
#         Incorporate that as a randomness element in the test.
# 49) Test of updateresync scenarios
#         A->B replication happens. A is at seqno 100. B is at seqno 50. And then A crashes.
#         Instead of bringing up B as primary, bring A up again as the primary.
#         But recreate the instance file on A. Now A is at 100 while B is at 50 but A has no history records.
#         So B has to use updateresync. Make sure B can NOT successfully connect to A with -updateresync.
#         The connection should fail with a REPLINSTNOHIST error.
#         This is because A has no way of sending 51 without also sending the corresponding history record for 51.
#         But it has no way of finding out what that is since the earliest history record it has is for 101.
#         Note: A,B could be either non-supplementary or supplementary instances and the behavior is expected to be the same.
#         Incorporate that as a randomness element in the test.
# 50) Same as (48) and (49) but without any crashes. It should be a controlled shutdown instead.
# xx) GTM-7371  REPLINSTDBSTRM error from source server after MUPIP JOURNAL ROLLBACK on supplementary instance in case the instance had no updates since the previous source server startup

if (! $?gtm_test_replay) then
	set crash = `$gtm_exe/mumps -run rand 2`
	source $gtm_tst/com/rand_suppl_type.csh
	echo "setenv crash $crash"					>>&! settings.csh
	echo "setenv test_replic_suppl_type $test_replic_suppl_type"	>>&! settings.csh
endif
# Test below requires more work to also run with nobefore images (which would in turn make it exercise forward rollback).
# It is not considered worth the extra effort since the cases tested here are very specific in terms of instance file handling
# (not journaling status) and forward rollback is tested in various other places.
# So, even if no-before is randomly selected, force it to before images now.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$MULTISITE_REPLIC_PREPARE 2

$gtm_tst/com/dbcreate.csh mumps 1 -rec=1000

set INST1_supplarg=""
set INST2_supplarg=""
set resume_initialize = "-initialize"
if (1 == $test_replic_suppl_type) then
	set INST2_supplarg="-supplementary"
	set resume_initialize = "-resume=1"
else if (2 == $test_replic_suppl_type) then
	set INST1_supplarg="-supplementary"
	set INST2_supplarg="-supplementary"
endif
$MSR START INST1 INST2
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 100 >>&! INST1_updates.out
$MSR SYNC INST1 INST2
$MSR STOPRCV INST1 INST2
echo "# Randomly crash or control shutdown INST1"
if ($crash) then
	$MSR CRASH INST1 >&! crash_inst1_1.out
else
	$MSR STOP INST1 >&! shutdown_inst1_1.out
endif
$MSR REFRESHLINK INST1 INST2
echo "# Rollback if crashed"
if ($crash) then
	$MSR RUN INST1 'set msr_dont_trace ;$gtm_tst/com/mupip_rollback.csh -losttrans=lost1.glo "*" >&! rollback1.out ;$grep -q JNLSUCCESS rollback1.out ;if ($status) echo "Rollback Failed"'
endif
$MSR RUN INST1 'set msr_dont_trace ; mv mumps.repl mumps.repl_precrash ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg''

# For A->B and P->Q connections instance file shoule be recreated on the receiver side too. If not done, starting rcvr with -updateresync=file.repl will error with
# %YDB-E-UPDSYNC2MTINS, Can only UPDATERESYNC with an empty instance file
# This recreation is not required in case of A->P
if (1 != $test_replic_suppl_type) then
	$MSR RUN INST2 'set msr_dont_trace ; mv mumps.repl mumps.repl_old ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME2 '$gtm_test_qdbrundown_parms $INST2_supplarg''
endif
setenv needupdatersync 1
$MSR STARTSRC INST1 INST2
unsetenv needupdatersync
$MSR STARTRCV INST1 INST2 "updateresync=srcinstback.repl $resume_initialize" >&! startrcv_inst1inst2_1.out
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 100 >>&! INST1_updates.out
$MSR SYNC INST1 INST2

# Test case 48) ends here. Now proceed with test case 49)
# The test case asks to do 100/50 updates on INST1/INST2. But already at this point there are 100 updates on INST1/INST2, so doing it with 200/100

$MSR STOPRCV INST1 INST2
$gtm_tst/com/simplegblupd.csh -instance INST1 -count 100 >>&! INST1_updates.out
echo "# Randomly crash or control shutdown INST1"
if ($crash) then
	$MSR CRASH INST1 >&! crash_inst1_2.out
else
	$MSR STOP INST1 >&! shutdown_inst1_2.out
endif
$MSR REFRESHLINK INST1 INST2
echo "# Rollback if crashed"
if ($crash) then
	$MSR RUN INST1 'set msr_dont_trace ;$gtm_tst/com/mupip_rollback.csh -losttrans=lost2.glo "*" >&! rollback2.out ;$grep -q JNLSUCCESS rollback2.out ;if ($status) echo "Rollback Failed"'
endif
$MSR RUN INST1 'set msr_dont_trace ; mv mumps.repl mumps.repl_precrash2 ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg''
if (1 != $test_replic_suppl_type) then
	$MSR RUN INST2 'set msr_dont_trace ; mv mumps.repl mumps.repl_old2 ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME2 '$gtm_test_qdbrundown_parms $INST2_supplarg''
endif
setenv needupdatersync 1
$MSR STARTSRC INST1 INST2
get_msrtime
unsetenv needupdatersync
echo "# Start the receiver with -updateresync and expect the source server to throw REPLINSTNOHIST and the receiver should exit"
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST1 INST2 "updateresync=srcinstback.repl $resume_initialize">&! startrcv_inst1inst2_2.out ; unsetenv gtm_test_repl_skiprcvrchkhlth
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log 'SRC_$time_msr.log' -message REPLINSTNOHIST'
$MSR RUN INST1 '$msr_err_chk 'SRC_$time_msr.log' E-REPLINSTNOHIST'
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-REPLINSTNOHIST
echo "# The receiver would have exited with the above error. Manually shutdown the passive server"
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -source -shutdown -timeout=0 >&! passivesrc_shut.out'
if (1 == $test_replic_suppl_type) then
	$MSR RUN INST2 'set msr_dont_trace ; set suppl_port = `cat portno_supp` ; $gtm_tst/com/portno_release.csh $suppl_port'
endif
$MSR REFRESHLINK INST1 INST2

# Test case 49) ends here. Proceed with testing GTM-7371

$MSR STOPSRC INST1 INST2
$MSR RUN INST1 'set msr_dont_trace ; mv mumps.repl mumps.repl_rollback ; $MUPIP replic -instance_create -name=$gtm_test_msr_INSTNAME1 '$gtm_test_qdbrundown_parms $INST1_supplarg''
$MSR STARTSRC INST1 INST2
$MSR STOPSRC INST1 INST2
$MSR RUN INST1 '$gtm_tst/com/mupip_rollback.csh -losttrans=lost3.glo "*" >&! rollback3.out ;$grep -q JNLSUCCESS rollback3.out ;if ($status) echo "Rollback Failed"'
$MSR STARTSRC INST1 INST2

# Since the last RCVR straup failed with YDB-E-REPLINSTNOHIST, the instances will not be in sync. Do not use -extract
$gtm_tst/com/dbcheck.csh
