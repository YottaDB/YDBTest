#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "Testing ZTWOrmhole with replication"
# Test must run with replication
if ($?test_replic != 1) then
	echo "Replication is not enabled. Exiting"
	exit 15
endif

# This test relies on the default region configuration, disable spanning regions
setenv gtm_test_spanreg 0

setenv gtm_trigger_etrap 'write $char(9),"$zlevel=",$zlevel," : $ztlevel=",$ztle," : $ZSTATUS=",$zstatus,! set $ecode=""'
# prepare local and remote directories
$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 3
unsetenv gtm_trigger_etrap

# start source and reciever
$MSR START INST1 INST2

$gtm_exe/mumps -run ^ztworepl

# need to verify the replicated journals and databases.
$MSR SYNC ALL_LINKS
$MSR STOP INST1 INST2
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst1_extracted_jnl_data.log
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst2_extracted_jnl_data.log
diff inst1_extracted_jnl_data.log inst2_extracted_jnl_data.log | $grep -E '^(<|>)'
cat inst1_extracted_jnl_data.log

echo ""
$echoline
echo "Check the detailed extract"
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh' > inst1_detailed_jnl_data.log
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/jnl_extract_detailed.csh' > inst2_detailed_jnl_data.log
$tst_awk '{print $0;if ($0 ~ /^.*KILL.*[ab]test.*$/){printf "---------\n";}}' inst1_detailed_jnl_data.log > inst1_detailed_jnl_data.logx
$tst_awk '{print $0;if ($0 ~ /^.*KILL.*[ab]test.*$/){printf "---------\n";}}' inst2_detailed_jnl_data.log > inst2_detailed_jnl_data.logx
diff inst1_detailed_jnl_data.logx inst2_detailed_jnl_data.logx | $grep -E '^(<|>)'
cat inst1_detailed_jnl_data.logx

$gtm_tst/com/dbcheck.csh -extract
