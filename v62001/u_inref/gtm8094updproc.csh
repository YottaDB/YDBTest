#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv test_encryption NON_ENCRYPT

source $gtm_tst/com/portno_acquire.csh >>& portno.out

$gtm_tst/com/dbcreate.csh mumps 1

$MUPIP set -replic=on -reg "*" >&! turnon_replication1.log

setenv gtm_repl_instance mumps.repl

$MUPIP replicate -instance_create -name=nullreceiver $gtm_test_qdbrundown_parms >&! create_instance1.log

$MUPIP replic -source -start -passive -log=source.log -instsecondary=nosource >&! start_passive_source_server1.log

# inhibit EXEC of update process
echo ""
echo "Prevent the EXEC of the update process"
echo ""
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 104

$MUPIP replic -receiv -start -listen=$portno -log=receiver1.logx

$grep YDB-E-UPDPROC receiver1.logx

$MUPIP replicate -receiver -shut -time=0 >&! shut_receiver1.log

$MUPIP replicate -source -shut -time=0 >&! shut_passive_source_server1.log

$MUPIP replicate -instance_create -name=nullreceiver $gtm_test_qdbrundown_parms >&! create_instance2.log

$MUPIP replic -source -start -passive -log=source.log -instsecondary=nosource >&! start_passive_source_server2.log

# Make gtm_dist too long for the update process
echo ""
echo "Make gtm_dist too long for the update process"
echo ""
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 114

$MUPIP replic -receiv -start -listen=$portno -log=receiver2.logx

$grep YDB-E-UPDPROC receiver2.logx

$MUPIP replicate -receiver -shut -time=0 >&! shut_receiver2.log

$MUPIP replicate -source -shut -time=0 >&! shut_passive_source_server2.log

$gtm_tst/com/portno_release.csh

$gtm_tst/com/dbcheck.csh
