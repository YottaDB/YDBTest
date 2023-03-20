#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# For this particular test, use just 1Mb of receive & jnlpool. Also cut down on the # of global buffers in
# each database (from say 1024 to say 64) this way you dramatically reduce the memory requirements of this test.
setenv tst_buffsize  1048576
$MULTISITE_REPLIC_PREPARE 2 17
$gtm_tst/com/dbcreate.csh mumps 5 125-425 900-1050 512,768,1024 4096 64 4096

setenv needupdatersync 1
$MSR START INST1 INST2 RP
foreach i (4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
	$MSR START INST3 INST$i RP
end
$MSR START INST1 INST3 RP
unsetenv needupdatersync

$gtm_tst/com/imptp.csh >&! imptp1.out
source $gtm_tst/com/imptp_check_error.csh imptp1.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh 1500 SRC 120 INSTANCE3 noerror
$gtm_tst/com/endtp.csh  >>& endtp1.out
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST3
foreach i (4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19)
	$MSR SYNC INST3 INST$i
end
$MSR STOP ALL_LINKS

foreach i (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18)
	$MSR START INST19 INST$i RP
end
$MSR START INST1 INST2 RP
$MSR START INST1 INST19 RP

$gtm_tst/com/imptp.csh >&! imptp2.out
source $gtm_tst/com/imptp_check_error.csh imptp2.out; if ($status) exit 1
$gtm_tst/com/wait_for_transaction_seqno.csh 1500 SRC 120 INSTANCE19 noerror
$gtm_tst/com/endtp.csh  >>& endtp2.out
$MSR SYNC INST1 INST2
$MSR SYNC INST1 INST19
foreach i (3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18)
	$MSR SYNC INST19 INST$i
end
$MSR STOP ALL_LINKS

$gtm_tst/com/dbcheck.csh -extract
