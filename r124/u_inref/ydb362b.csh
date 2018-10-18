#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.      #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# Subtest must be run on a Pro version to work because for versions Pre-V6.0, there are no dbg builds.
#
# Following Environmental Settings are set due to Pre-V6.0 Versions
setenv test_replic_suppl_type 0
setenv gtm_test_qdbrundown 0
setenv gtm_test_qdbrundown_parms ""
setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS"
setenv test_no_ipv6_ver 1
setenv gtm_test_embed_source "FALSE"
unsetenv gtmcompile
setenv gtm_test_repl_skipsrcchkhlth 1 #We skip SRC.csh's checkhealth as we expect an error

echo "--------------------------------------------------------------------------------------------------------------------------------------"
echo "# Test that connecting a pre-V60000 Receiver server to a current source server gives a YDB-E-UNIMPLOP/YDB-I-TEXT error in source side."
echo "--------------------------------------------------------------------------------------------------------------------------------------"
echo "# Choose a random version prior to V60000"
set rand_ver=`$gtm_tst/com/random_ver.csh -lt V60000`
source $gtm_tst/com/ydb_prior_ver_check.csh $rand_ver
echo "rand_ver: $rand_ver" > debug.txt

echo "# Generate config file for Replication"
$MULTISITE_REPLIC_PREPARE 2

echo "# Alter the msr_instance_config file to update the receiver side version with the older version"
sed -i -r '/INST2[[:blank:]]VERSION:/s/'"$tst_ver"'/'"$rand_ver"'/g' msr_instance_config.txt
echo "------------------------------------------------------------------------------------------------"
echo "# Create a single region DB with region DEFAULT"
$gtm_tst/com/dbcreate.csh mumps >>& dbcreate_log.txt
if ($status) then
	echo "DB Create Failed, Output Below"
	cat dbcreate_log.txt
endif

echo "------------------------------------------------------------------------------------------------"

echo "# Start the source server and receiver server"
$MSR STARTSRC INST1 INST2
get_msrtime # obtain msr time when source has started
$MSR STARTRCV INST1 INST2

echo "# Waiting for Source instance to die"
set pid=`grep "Pid" SRC_${time_msr}.log | cut -d'[' -f 2 | cut -d']' -f 1`
echo "SRC Pid: $pid" >> debug.txt
$gtm_tst/com/wait_for_proc_to_die.csh $pid 100

echo "# Stop the receiving instance"
$MSR STOPRCV INST1 INST2

echo "------------------------------------------------------------------------------------------------"

echo '# Use $msr_err_chk to search the SRC_*.log file for YDB-E-UNIMPLOP and YDB-I-TEXT errors'
$msr_err_chk SRC_${time_msr}.log YDB-E-UNIMPLOP YDB-I-TEXT

echo "# Start and Stop the source instance to clear up remaining ipcs"
$MSR STARTSRC INST1 INST2
$MSR STOPSRC INST1 INST2
