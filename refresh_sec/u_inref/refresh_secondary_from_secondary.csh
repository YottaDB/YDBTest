#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
######################################################################################
# Test is to refresh a secondary from another secondary (in case the secondary is in an unsalvagable condition)
######################################################################################
# This test copied .repl file from one secondary to the other and starts with -updateresync qualifier, A->P scheme won't work
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
$echoline
cat << EOF

        |--> INST2
INST1  -|
        |--> INST3

EOF
$echoline
#
$MULTISITE_REPLIC_PREPARE 3
$gtm_tst/com/dbcreate.csh mumps 1 255 1000 -allocation=2048 -extension_count=2048
$MSR START INST1 INST2
$MSR START INST1 INST3
echo "Starting GTM processes..."
$gtm_tst/com/imptp.csh >>&! imptp.out
source $gtm_tst/com/imptp_check_error.csh imptp.out; if ($status) exit 1
setenv gtm_test_jobcnt 1
setenv gtm_test_dbfill "SLOWFILL"
sleep 3
$MSR STOPRCV INST1 INST3 ON "''" "buffer_flush"
echo "Create backlog..."
sleep 3
# online backup
# sometimes we get shmpool lock messages from processes randomly.Filter it out from reference file
$MSR RUN INST2 'mkdir bak1;$MUPIP backup -replinstance=bak1 "*" bak1 >&! inst2_bkup.out;$grep -v "shmpool lock" inst2_bkup.out; mv bak1/mumps.repl bak1/sec_mumps.repl'
# save old INST3 databases
$MSR RUN INST3 'set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh olddb "*.dat *.mjl" mv'
$MSR RUN SRC=INST2 RCV=INST3 'cp bak1/* __RCV_DIR__/'
if ("ENCRYPT" == $test_encryption) then
$MSR RUN SRC=INST2 RCV=INST3 'cp *key* __RCV_DIR__/'
endif
# replication instance file be created with -supplementary option for A->P and P->Q situations i.e if test_replic_suppl_type is 1 or 2
set supplarg = ""
if ((1 == $test_replic_suppl_type) || (2 == $test_replic_suppl_type)) then
	set supplarg = "-supplementary"
endif
$MSR RUN INST3 'set msr_dont_trace ; $MUPIP replic -instance_create -name=__SRC_INSTNAME__ '$supplarg' '$gtm_test_qdbrundown_parms''
# signal jnl_on.csh to use -file while turning on journaling, as the db copied from INST1 will have jnl file pointing INST1
setenv test_jnl_on_file 1
$MSR STARTRCV INST1 INST3 updateresync=sec_mumps.repl
unsetenv test_jnl_on_file
echo "Stopping GTM processes..."
$MSR RUN INST1 '$gtm_tst/com/endtp.csh >>&! endtp.out'
$MSR SYNC ALL_LINKS
$gtm_tst/com/dbcheck.csh -extract INST1 INST2 INST3
#
