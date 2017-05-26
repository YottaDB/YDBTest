#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Supplementary instance testing can cause the remote side to have different triggers installed
unsetenv gtm_test_extr_no_trig
if ($?test_replic && $?test_replic_suppl_type) then
	if ($test_replic_suppl_type == 1) setenv gtm_test_extr_no_trig 1
endif

$gtm_tst/com/dbcreate.csh mumps
echo "----------------------------------------------------------------"
echo "# Test for MREP <imptp_process_terminates> (spurious trigger-already-exists error from trigger inserts)"
if ($?gtm_test_extr_no_trig) then
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run remote^gtm7522d"
endif
$gtm_exe/mumps -run gtm7522d

if ($?gtm_test_extr_no_trig) then
	# It's possible that a FREEZE could delay the propagation of ^stop=1, so wait for the main backgroup process to terminate
	$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_dist/mumps -run remotewait^gtm7522d"
endif
$gtm_tst/com/dbcheck.csh -extract	>& dbcheck.log
