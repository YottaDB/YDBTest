#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2015 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that the Receiver Server started with -autorollback (set in instream) does not shut down after an online
# rollback that does not change it's state

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 3 125 450 512 4096 1024 4096 >&! dbcreate1.log

$echoline
$MSR START INST1 INST2 RP
get_msrtime
set ts = $time_msr

# For INST2 to freeze before any updates are processed. Thus when the Receiver side is unfrozen, the Receiver
# Server will attempt to perform the ONLINE ROLLBACK before it has applied any updates.
$MSR RUN INST2 '$MUPIP replicate -source -freeze=on -nocomment'

# Do some updates
$gtm_dist/mumps -run %XCMD 'for i=1:1:10 set (^a(i),^b(i),^c(i))=i'

# Now rollback all data. The Receiver Server on INST2 should remain active. If it does not, the MSR scripts will
# time out at the end while shutting down the Receiver side
$echoline
echo "Rollback with -online -resync=1"
echo $MUPIP journal -online -rollback -backward -resync=1 "*" 	>>& orlbk_resync1.outx
$MUPIP journal -online -rollback -backward -resync=1 "*" 	>>& orlbk_resync1.outx
$tst_awk -f $gtm_tst/$tst/inref/checkoutput.awk rollseqno=1 orlbk_resync1.outx

# Unfreeze INST2
$echoline
$MSR RUN INST2 '$MUPIP replicate -source -freeze=off -nocomment'

# Wait for online rollback to complete
$MSR RUN INST2 "set msr_dont_trace;$gtm_tst/com/wait_for_log.csh -log RCVR_${ts}.log -message ORLBKCMPLT"

# Replay updates to set the seqnos correctly across all instances
$gtm_dist/mumps -run %XCMD 'for i=1:1:10 set (^a(i),^b(i),^c(i))=i'

$echoline
$gtm_tst/com/dbcheck_filter.csh -extract

