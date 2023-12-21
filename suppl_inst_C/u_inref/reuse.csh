#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#                                                               #
# Copyright (c) 2017-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test the -REUSE qualifier

$MULTISITE_REPLIC_PREPARE 2 2
$gtm_tst/com/dbcreate.csh mumps -rec=1000

setenv needupdatersync 1
$MSR START INST3 INST4 RP
$MSR START INST2 INST3 RP
unsetenv needupdatersync
$gtm_tst/com/simplegblupd.csh -instance INST2 -count 1 >>& updates.log
$MSR SYNC INST2 INST3
$MSR STOP INST2 INST3
$MSR STARTSRC INST1 INST3 RP
$MSR RUN INST1 "mkdir -p back_reuse; $MUPIP backup -replinstance=back_reuse "'"*" back_reuse' >>&! backup.log
$MSR RUN SRC=INST1 RCV=INST3 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/back_reuse/mumps.repl _REMOTEINFO___RCV_DIR__/INSTANCE1.repl' >>&! cp_remote_file.logx

# For an A->P connection -updateresync requires -INITIALIZE or -RESUME. Not specifying one of them will error out with INITORRESUME. Test that here
$MSR STARTRCV INST1 INST3 "updateresync=INSTANCE1.repl -reuse=INSTANCE2"
get_msrtime
$MSR RUN INST3 "$msr_err_chk START_$time_msr.out INITORRESUME"
$gtm_tst/com/knownerror.csh $msr_execute_last_out YDB-E-INITORRESUME
$MSR STARTRCV INST1 INST3 "updateresync=INSTANCE1.repl -initialize -reuse=INSTANCE2"
get_msrtime
$MSR RUN INST3 '$gtm_tst/com/wait_for_log.csh -log RCVR_'$time_msr'.log.updproc -message "New History Content" -duration 30'
$MSR RUN INST3 '$MUPIP replic -edit -show mumps.repl' >&! INST3_show_repl.out
echo "# Check the Stream number in history records of INSTANCE 3"
$grep -E '^HST.*Stream #' INST3_show_repl.out

echo "# Restart source server. Test that the receiver server continues to operate fine across the connection reset."
echo "# Before r2.00 (when GTM-94146 fixes in GT.M V7.0-001 got merged), the receiver server would terminate with a"
echo "# %YDB-E-REUSEINSTNAME in this connection reset situation. We don't expect to see any such errors now."
$MSR STOPSRC INST1 INST3 RP
$MSR STARTSRC INST1 INST3 RP

# INST1 does not have updates of INST2, so -extract cannot be used
$gtm_tst/com/dbcheck.csh
