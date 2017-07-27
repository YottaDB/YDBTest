#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#35) Start A->P replication. You will need to use -updateresync when starting up receiver on P.
#	Do updates on A and some updates on P. On P, one should be able to see both sets of updates.
#	Now shut down the receiver and source server on P.
#	Now restart the source server and receiver on P using the same -updateresync command and same input instance file.
#	You expect to see the history records of A written TWICE in the instance file of P.
#	In addition, there would be TWO history records written by P itself one for each source server startup.
#	For a total of 4 history records in the order P, A, P, A.
#	This verifies that even though the history record of A written in both cases is identical, we write them twice
#	because the "Start Sequence Number" field of those two A history records are different. The test should verify this.

$MULTISITE_REPLIC_PREPARE 2 2

$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024 4096 1024 4096

setenv needupdatersync 1
$MSR START INST1 INST2 RP
$MSR START INST3 INST4 RP
$MSR START INST1 INST3 RP
unsetenv needupdatersync

$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "for i=1:1:5 set ^INST1(i)=i"'
$MSR RUN INST3 '$gtm_dist/mumps -run %XCMD "for i=1:1:5 set ^INST3(i)=i"'

$MSR SYNC ALL_LINKS

$MSR STOP INST1 INST3
$MSR STOP INST3 INST4
$MSR START INST3 INST4 RP
$MSR STARTSRC INST1 INST3 RP

# For an A->P connection -updateresync requires -INITIALIZE or -RESUME. Not specifying one of them will error out with INITORRESUME. Test that here
$MSR STARTRCV INST1 INST3 "updateresync=srcinstback.repl"
get_msrtime
$MSR RUN INST3 "$msr_err_chk START_$time_msr.out INITORRESUME"
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-INITORRESUME
$MSR STARTRCV INST1 INST3 "updateresync=srcinstback.repl -initialize"
get_msrtime
$MSR RUN INST3 "set msr_dont_trace ; $gtm_tst/com/wait_for_log.csh -log RCVR_$time_msr.log.updproc -message 'New History Content'"

$MSR RUN INST1 '$gtm_dist/mumps -run %XCMD "for i=6:1:15 set ^INST1(i)=i"'
$MSR RUN INST3 '$gtm_dist/mumps -run %XCMD "for i=6:1:15 set ^INST3(i)=i"'
$MSR SYNC ALL_LINKS

$MSR RUN INST3 '$MUPIP replic -edit -show mumps.repl' >&! INST3_repl_show.out
$grep 'Start Sequence Number' INST3_repl_show.out

$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck.csh -extract
