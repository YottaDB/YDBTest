#!/usr/local/bin/tcsh -f
#################################################################
#                                                               #
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.       #
# All rights reserved.                                          #
#                                                               #
#       This source code contains the intellectual property     #
#       of its copyright holder(s), and is made available       #
#       under a license.  If you do not know the terms of       #
#       the license, please stop and do not read further.       #
#                                                               #
#################################################################
#
# Subtest must be run on a Pro version to work because for versions Pre-V6.0 there are no dbg builds.
#
# Following Environmental Settings are set due to Pre-V6.0 Versions
setenv test_replic_suppl_type 0
setenv gtm_test_qdbrundown 0
setenv gtm_test_qdbrundown_parms ""
setenv gtm_test_dynamic_literals "NODYNAMIC_LITERALS"
setenv test_no_ipv6_ver 1
setenv gtm_test_embed_source "FALSE"
unsetenv gtmcompile
setenv gtm_test_repl_skiprcvrchkhlth 1	# We skip receiver server checkhealth as we expect an error

echo "----------------------------------------------------------------------------------------------------------------------------------------"
echo "# Test that connecting a pre-V60000 Source server to a current receiver server gives a YDB-E-UNIMPLOP/YDB-I-TEXT error in receiver side."
echo "----------------------------------------------------------------------------------------------------------------------------------------"
echo "# Choose a random version prior to V60000"
set rand_ver=`$gtm_tst/com/random_ver.csh -lt V60000`
source $gtm_tst/com/ydb_prior_ver_check.csh $rand_ver
echo "rand_ver: $rand_ver" > debug.txt

echo "# Generate config file for Replication"
$MULTISITE_REPLIC_PREPARE 2

echo "# Alter the msr_instance_config file to update the source side version with the older version"
sed -i -r '/INST1[[:blank:]]VERSION:/s/'"$tst_ver"'/'"$rand_ver"'/g' msr_instance_config.txt
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
$MSR STARTRCV INST1 INST2
get_msrtime # obtain msr time when receiver has started
echo "RCVR MSR Time: $time_msr" >> debug.txt

echo "# Waiting for Reciever instance to die"
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth >& checkhealth.tmp ; cat checkhealth.tmp' >& checkhealth.out
set pid = `$tst_awk '/PID.*Receiver/{print $2}' checkhealth.out`
echo "RCVR Pid: $pid" >> debug.txt
$gtm_tst/com/wait_for_proc_to_die.csh $pid 100

echo "# Stop the source instance"
$MSR STOPSRC INST1 INST2

echo "------------------------------------------------------------------------------------------------"
echo '# Use $msr_err_chk to search the RCVR_*.log file for YDB-E-UNIMPLOP and YDB-I-TEXT errors'
$MSR RUN INST2 'set msr_dont_trace; $msr_err_chk RCVR_'"${time_msr}"'.log UNIMPLOP TEXT'
$msr_err_chk $msr_execute_last_out UNIMPLOP TEXT > execute.outx

echo "# Start and Stop the receiving instance to clear up remaining ipcs"
$MSR STARTRCV INST1 INST2
$MSR STOPRCV INST1 INST2

# Starting/Stoping the Receiving instance starts a Passive source, which means we need to shut that down.
$MSR RUN RCV=INST2 SRC=INST1 '$MUPIP replic -source -shutdown -timeout=0 -instsecondary=__SRC_INSTNAME__  >&! passivesrc_shut_INST1INST2.out'

	#$gtm_tst/com/backup_dbjnl.csh iteration$iter '*.gld *.dat *.mjl* *.o *.repl*' mv nozip

	#$gtm_tst/com/dbcheck.csh >>& dbcheck_log.txt
	#if ($status) then
	#	echo "DB Check Failed, Output Below"
	#	cat dbcheck_log.txt
	#endif
