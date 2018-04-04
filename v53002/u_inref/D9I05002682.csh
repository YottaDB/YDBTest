#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2008-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9I05-002682 Update process should disallow updates to non-replicated databases
#
# copy the file jnl_on_specific_dblist.txt to secondary side to bypass the default journaling on done by com/jnl_on.csh.
# Instead of enabling journal/replic in all the database files, jnl_on.csh will do it only for
# the database files listed in the file jnl_on_specific_dblist.txt.
# in this specific subtest only mumps.dat and a.dat should have replication enabled on the secondary side
#
setenv gtm_test_sprgde_exclude_reglist BREG # Replication is disabled for BREG and error messages expect ^bglobal
$MULTISITE_REPLIC_PREPARE 2
$MSR RUN RCV=INST2 SRC=INST1 'cp $gtm_tst/$tst/inref/jnl_on_specific_dblist.txt .'
$gtm_tst/com/dbcreate.csh mumps 3
$MSR START INST1 INST2
get_msrtime
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replicate -receiver -checkhealth' >&! checkhealth_INST2_1.out
set updproc_pid = `$tst_awk '/Update process/ {print $2}' checkhealth_INST2_1.out`
# On the primary do a few updates to AREG, BREG, DEFAULT
$GTM << EOF
for i=1:1:10 set ^aglobal(i)=i set ^bglobal(i)=i set ^default(i)=i
EOF

# Check if the above updates caused the update process to die with a YDB-E-UPDREPLSTATEOFF error
# while trying to update the non-replicated region BREG.
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log.updproc' -message UPDREPLSTATEOFF'
$MSR RUN INST2 "$msr_err_chk RCVR_$time_msr.log.updproc UPDREPLSTATEOFF"
# The above MSR run will have UPDREPLSTATEOFF in the msr_execute_xx.out file, filter it out
$gtm_tst/com/knownerror.csh $msr_execute_last_out UPDREPLSTATEOFF

$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh '$updproc_pid' 120'

# Run checkhealth to see status of update process
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replicate -receiver -checkhealth' >&! checkhealth_INST2_2.out
sed 's/PID [0-9]* /PID ##FILTERED##[##PID##] /' checkhealth_INST2_2.out

# Shut down the replication servers on the secondary.
$MSR STOPRCV INST1 INST2

# Try to restart the replication servers on the secondary.
# Since there is an update waiting to be applied, the update process will die with the same YDB-E-UPDREPLSTATEOFF error
setenv msr_dont_chk_stat
$MSR STARTRCV INST1 INST2
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log.updproc' -message UPDREPLSTATEOFF'
$MSR RUN INST2 "$msr_err_chk RCVR_$time_msr.log.updproc UPDREPLSTATEOFF"
# The above MSR run will have UPDREPLSTATEOFF in the msr_execute_xx.out file, filter it out
$gtm_tst/com/knownerror.csh $msr_execute_last_out UPDREPLSTATEOFF
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replicate -receiver -checkhealth' >&! checkhealth_INST2_3.out
set updproc_pid = `$tst_awk '/Update process/ {print $2}' checkhealth_INST2_3.out`
$MSR RUN INST2 'set msr_dont_trace ; $gtm_tst/com/wait_for_proc_to_die.csh '$updproc_pid' 120'

$MSR STOPRCV INST1 INST2
# Turn replication ON in region BREG.
echo "# Turn replication ON in region BREG. (MSR action command not printed)"
$MSR RUN INST2 'set msr_dont_trace ; $MUPIP set -file b.dat '${tst_jnl_str}',file=b.mjl -replic=on >&! set_jnlreplic_on.out ; $grep YDB-I-REPLSTATE set_jnlreplic_on.out'
# Start the replication servers on the secondary. Now it should start successfully.
$MSR STARTRCV INST1 INST2
# Now do RF_sync. This should succeed.
$MSR SYNC INST1 INST2

$gtm_tst/com/dbcheck.csh -extr
