#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv acc_meth "BG" # Before image journaling does not work with MM
# Online rollback does not do backward processing without before image
setenv gtm_test_jnl_nobefore 0
setenv tst_jnl_str "-journal=enable,on,before"
# Online rollback does not process V4 format
setenv gtm_test_mupip_set_version "disable"

setenv gtm_usesecshr 1
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 99 # WBTEST_HOLD_GTMSOURCE_SRV_LATCH

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps

# Active source server should hang onto server latch
$MSR START INST1 INST2 RP

# Online rollback should wait on the server latch and send SIGCONTs to source server
set syslog_before = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/mupip_rollback.csh -online "*" |& $grep -v "YDB-I-RLBKSTRMSEQ"
$gtm_tst/com/getoper.csh "$syslog_before" "" syslog1.txt "" "Process [0-9]* was requested to resume processing"
$grep "GTMSECSHRSRVFID" syslog1.txt
if (0 == $status) then
    echo "GTMSECSHRSRVFID is found in the syslog. See syslog1.txt"
endif
$gtm_tst/com/dbcheck.csh
