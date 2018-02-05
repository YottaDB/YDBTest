#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
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
# This test case goes back to original test case in which the Receiver Server
# is tricked into loading an Update Process and Helper Processes belonging to a
# different version of GT.M. After GTM-7926 the Receiver Server does not start
# if it cannot validate $gtm_dist.
#

# Encryption adds another layer of fungibility here, so disable it
setenv test_encryption NON_ENCRYPT

# Get port reservation
source $gtm_tst/com/portno_acquire.csh >>& portno.out

# Get an alternate prior version
set prior_ver = `$gtm_tst/com/random_ver.csh -type any`
if ("$prior_ver" =~ "*-E-*") then
        echo "No prior versions available: $prior_ver"
        exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "$prior_ver" > priorver.txt

# Setup db env
$gtm_tst/com/dbcreate.csh mumps 1

setenv gtm_poollimit 0 # gtm_poollimit settings are not properly handled by versions prior to V63000A

# Enable journaling and replication
$gtm_exe/mupip set -region "*" -journal=enable,on,nobefore -replic=on >&! enable_replication.log

# Start up the passive source server
setenv gtm_repl_instance mumps.repl
$gtm_dist/mupip replicate -instance -name=nullreceiver $gtm_test_qdbrundown_parms >&! create_inst.log
$gtm_dist/mupip replic -source -start -passive -log=PASSIVE.log -instsecondary=nosource >&! start_passive.log

$echoline
env ydb_dist=$gtm_root/$prior_ver/$tst_image gtm_dist=$gtm_root/$prior_ver/$tst_image $ydb_dist/mupip replic -receiv -start -listen=$portno -log=RCVR.log -helper
if ($status) then
	echo "TEST-F-FAIL. Expecting no issues starting receiver server with a mismatched ydb_dist/gtm_dist"
else
	echo "TEST-I-PASS. Receiver server and Update process with a mismatched ydb_dist/gtm_dist started fine"
	$gtm_dist/mupip replicate -receiver -shut -time=0 >&! shut_receiver1.log
endif

$echoline
set origpath=($path)
set path=($gtm_dist $origpath)
env ydb_dist=$gtm_root/$prior_ver/$tst_image gtm_dist=$gtm_root/$prior_ver/$tst_image mupip replic -receiv -start -listen=$portno -log=RCVR.log -helper
if ($status) then
	echo "TEST-F-FAIL. Expecting no issues starting receiver server with a hidden ydb_dist/gtm_dist"
else
	echo "TEST-I-PASS. Receiver server and Update process with a hidden ydb_dist/gtm_dist started fine"
	$gtm_dist/mupip replicate -receiver -shut -time=0 >&! shut_receiver2.log
endif

set path=($origpath)

$gtm_dist/mupip replicate -source -shut -time=0 >&! shut_passive.log

# Release port reservation
$gtm_tst/com/portno_release.csh

$gtm_tst/com/dbcheck.csh

