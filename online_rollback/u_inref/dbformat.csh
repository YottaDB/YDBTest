#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This test verifies if database has V4 blocks, online rollback does not start
# 3)	ONLINE ROLLBACK errors out immediately if database has V4 block. (dbformat.csh)
# 	-	dse change -file -full_upgraded=No
# 	-	ONLINE ROLLBACK issues an error (The error message has not been decided yet)

$echoline
setenv gtm_test_mupip_set_version	"V4"	# test ONLINE ROLLBACK with V4 format databases
setenv test_encryption		  	"NON_ENCRYPT"
setenv gtm_test_disable_randomdbtn	1
echo "Start source server and receiver server with journaling enabled"
echo "# force a V4 format for the DB"				>> settings.csh
echo "setenv gtm_test_mupip_set_version V4"			>> settings.csh
echo "# encryption does not work with a V4 DB format"		>> settings.csh
echo "setenv test_encryption		NON_ENCRYPT"		>> settings.csh

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1 125 1000 1024

# start source and reciever server
$MSR START INST1 INST2 RP
get_msrtime
set ts = $time_msr

$echoline
echo "Switch to a V4 DB block structure and use v4imptp for some updates"
$MUPIP set -file -version=V4 mumps.dat

setenv gtm_test_jobid 1
setenv gtm_test_dbfillid 1
$gtm_tst/com/v4imptp.csh >>&! v4imptp.out

# wait for at least 100 updates
$gtm_exe/mumps -run waituntilseqno "jnl" 0 100  >>&! last_seqno.csh
source last_seqno.csh
# shut down v4imptp
$gtm_tst/com/v4endtp.csh >>&! v4imptp.out

$echoline
echo "Switch to a V6 DB block structure and use imptp for some updates"
$MUPIP set -file -version=V6 mumps.dat

# start some imptp updates
setenv gtm_test_jobid 2
setenv gtm_test_dbfillid 2
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1

# wait for at least another 100 updates
$gtm_exe/mumps -run waituntilseqno "jnl" $lastseqno 100 >>&! last_seqno.csh
# shut down imptp
$gtm_tst/com/endtp.csh >>&! endtp.out

# Use ORB
$echoline

$gtm_tst/com/mupip_rollback.csh -online "*" >&! orlbk.outx
$grep -E '(YDB-E-|JNLSUCCESS|ORLBKCMPLT)' orlbk.outx

# TODO do I need to check syslog?

$echoline
$MSR SYNC ALL_LINKS
$MSR RUN INST2 "set msr_dont_trace;mv RCVR_${ts}.log{,x};$grep -v MUKILLIP RCVR_${ts}.logx >&! RCVR_${ts}.log"
$gtm_tst/com/dbcheck_filter.csh -extract -noonline
