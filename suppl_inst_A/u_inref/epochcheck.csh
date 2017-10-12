#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# 15) Test that 16 strm_seqnos are dumped in EPOCH record as part of detailed journal extract.
setenv test_replic_suppl_type 1
setenv gtm_test_plaintext_fallback
$MULTISITE_REPLIC_PREPARE 17
# SSL/TLS support in the framework allows only for INSTANCE1 - INSTANCE16. INSTANCE17 is higher than that. So, set the below env.
# variable to allow to fallback to plaintext without issuing an error whenever possible.
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
setenv needupdatersync 1
foreach i (1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 )
	$MSR START INST$i INST17
	$MSR RUN INST$i '$gtm_dist/mumps -run %XCMD "set ^global('$i')='$i'"'
	if (15 == $i) $MSR RUN INST17 '$gtm_dist/mumps -run %XCMD "set ^global(17)=17"'
	$MSR SYNC INST$i INST17
	$MSR STOP INST$i INST17
end

#%GTM-E-UPDSYNCINSTFILE, Error with instance file name specified in UPDATERESYNC qualifier
#%GTM-I-TEXT, No empty slot found. Specify REUSE to choose one for reuse
echo "# Expect the rcvr to exit with UPDSYNCINSTFILE if a 16th server is connected to supplementary instance P"
$MSR STARTSRC INST16 INST17
setenv gtm_test_repl_skiprcvrchkhlth 1 ; $MSR STARTRCV INST16 INST17  >&! STARTRCV_INST16_INST17.outx ; unsetenv gtm_test_repl_skiprcvrchkhlth
get_msrtime
$MSR RUN INST17 '$gtm_tst/com/wait_for_log.csh -log 'RCVR_$time_msr.log' -message UPDSYNCINSTFILE -duration 120 -waitcreation'
$MSR RUN INST17 "$msr_err_chk RCVR_$time_msr.log UPDSYNCINSTFILE"
$gtm_tst/com/knownerror.csh $msr_execute_last_out GTM-E-UPDSYNCINSTFILE
echo "# The receiver would have exited with the above error. Manually shutdown the update process and passive server"
$MSR RUN INST17 'set msr_dont_chk_stat ;$MUPIP replic -receiver -shutdown -timeout=0 >&! updateproc_shut_INST16INST17.out'
$MSR RUN INST17 '$MUPIP replic -source -shutdown -timeout=0 >&! suppl_shut_INST17.out'
$MSR RUN INST17 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'

$MSR RUN INST17 'set files = `ls mumps.mjl*`;set mjls = `echo $files | sed "s/ /,/g"` ;$MUPIP journal -extract=mumps.mjf -detail -forward $mjls >&! jnl_extr.out'
$MSR RUN SRC=INST1 RCV=INST17 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/mumps.mjf  __SRC_DIR__/mumps.mjf' >&! transfer_mumps.mjf.out
$MSR STOPSRC INST16 INST17
$MSR REFRESHLINK INST16 INST17

echo "# Should see 16 stream numbers and stream sequence numbers (separated by spaces)"
$tst_awk -F \\ '/EPOCH/ { for (i=1; i<=11; i++) {$i=""} strms=$0} END {print strms}' mumps.mjf
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
