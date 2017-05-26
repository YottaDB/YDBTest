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
# This test should be kept in sync with replictrigger
#
# This test is meant to test the two warning messages that are put in
# the source server log when the replicating instance does not support
# triggers.
#
# There are two types of warnings.
# - The first warning:
# 	Warning : Secondary does not support GT.M database triggers. #t
# 	updates on primary will not be replicated
# Alerts to the fact that the replicating instance does not support
# triggers this any ^#t records (aka trigger installations) that occur
# on the primary will not make it to the replicating instance.
#
# - The second warning:
# 	Warning: Sending transaction sequence number 3 which used triggers
# 	to a replicator that does not support triggers
# Alerts when triggers are installed on the primary, indicating that the
# triggers will not be sent to the secondary.

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh

# prepare local and remote directories
$MULTISITE_REPLIC_PREPARE 2

# set the remote prior version
# V51000 is the first version that supported multisite replic and V53004A does not support triggers
set remote_prior_ver=`$gtm_tst/com/random_ver.csh -gte V51000 -lt V54000`
if ("$remote_prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $remote_prior_ver"
	exit -1
endif
echo $remote_prior_ver >& prior_ver.txt
echo "Randomly chosen pre-V54000 version is GTM_TEST_DEBUGINFO: [$remote_prior_ver]"

# switch to prior version
# unconditionally switch to the PRO image because versions prior to V54000A will
# ASSERT in DBG_CHECK_GVTARGET_CSADDRS_IN_SYNC of op_tsart
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if("INST2" == $1){if("VERSION:" == $2){sub("'$tst_ver'","'$remote_prior_ver'")};if("IMAGE:" == $2){sub("dbg","pro")}};print}' msr_instance_config.bak >&! msr_instance_config.txt
$MULTISITE_REPLIC_ENV

# provide a source server log file name
setenv SRC_LOG_FILE "$PRI_SIDE/src_startup.log"
$gtm_tst/com/dbcreate.csh mumps 5
unsetenv gtm_gvdupsetnoop

# start source and reciever
$MSR START INST1 INST2

# check the updated process's log for the error message of the secondary not supporting triggers
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log src_startup.log -message Warning -grep -duration 300'

# send one update over
$gtm_exe/mumps -run initiator^trig2notrig

# Rotate the source server's log file to a desired name
# Fancy option:
#   $MSR RUN SRC=INST1 RCV=INST2 '$MUPIP replic -source -changelog -log=src_nexterror.log -instsecondary=__RCV_INSTNAME__'
# Best option
#   $MUPIP replic -source -changelog -log=src_nexterror.log -instsecondary=$gtm_test_cur_sec_name
# Simple option: this works because INST1 is the local machine
#   setenv gtm_repl_instsecondary $gtm_test_cur_sec_name
#   $MUPIP replicate -source -changelog -log=src_nexterror.log
$MUPIP replic -source -changelog -log=src_nexterror.log -instsecondary=$gtm_test_cur_sec_name
# wait for src_nexterror.log
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log src_nexterror.log -duration 300'

# kill the dummy update
$gtm_exe/mumps -run kill^trig2notrig

# begin trigger related updates to cause the next error by replicating ^#t records
$gtm_exe/mumps -run trig2notrig >&! trig2notrig.outx

# check for error message in src_nexterror.log
echo "Check for TRIG2NOTRIG warning (error type not printed)"
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log src_nexterror.log -message Warning -grep -duration 300'
$echoline
echo ""

# make sure everything worked as it's supposed to
cat trig2notrig.outx

# need to verify the replicated journals and databases.
$MSR STOP INST1 INST2
$echoline
echo ""
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst1_extracted_jnl_data.log
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst2_extracted_jnl_data.log
echo "^#t references on the primary `fgrep -c '^#t' inst1_extracted_jnl_data.log`"
echo "^#t references on the secondary `fgrep -c '^#t' inst2_extracted_jnl_data.log`"
$echoline
echo ""

$gtm_tst/com/dbcheck.csh -extract
