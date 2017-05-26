#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2004-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# journal enable is done in this test. So let's not randomly enable journaling in dbcreate.csh
setenv gtm_test_jnl NON_SETJNL
#
setenv gtm_repl_instance mumps.repl
setenv gtm_repl_instname INSTANCE1
$gtm_tst/com/dbcreate.csh mumps 1 255 8000 16384 1024 1024 1024
$gtm_tst/com/passive_start_upd_enable.csh >>& passive_start.out
# In a fast machine all the updates can happen in one second
# Following is so that rollback does not come to the first generation journal file
sleep 2
$MUPIP set -repli=on -journal=enable,on,before,align=1048576 -reg "*"
$gtm_tst/com/backup_for_mupip_rollback.csh	# needed because this test does not turn on replication using dbcreate.csh
$GTM << aaa
d set1^c9d2473
h
aaa
sleep 2
$GTM << aaa
d set2^c9d2473
h
aaa
$MUPIP replic -source -shutdown -timeout=0 >>& passive_stop.out
source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
$gtm_tst/com/backup_dbjnl.csh save '*.gld *.repl *.dat *.mjl*' cp nozip
$gtm_tst/com/mupip_rollback.csh -resync=299 "*"
$GTM << aaa
d verify^c9d2473
h
aaa
$gtm_tst/com/dbcheck.csh
