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

$MUPIP set -replic=on -reg "*" >&! turnon_replication.log

setenv gtm_repl_instance mumps.repl

$MUPIP replicate -instance_create -name=nullreceiver $gtm_test_qdbrundown_parms >&! create_instance.log

$MUPIP replic -source -start -passive -log=source.log -instsecondary=nosource >&! start_passive_source_server.log

# Note: the -filter qualifier is intentionally done incorrectly since we want an exec() failure
echo ""
echo "Prevent the filter from starting"
echo ""
$MUPIP replic -receiv -start -listen=$portno -log=receiver.logx -filter='"$gtm_dist/mumps -run $gtm_tst/$tst/inref/nullfilter.m"'

$gtm_tst/com/wait_for_log.csh -log receiver.logx -message "YDB-E-REPLFILTER" -grep

$MUPIP replicate -receiver -shut -time=0 >&! shut_receiver.log

$MUPIP replicate -source -shut -time=0 >&! shut_passive_source_server.log

$gtm_tst/com/portno_release.csh

$gtm_tst/com/dbcheck.csh
