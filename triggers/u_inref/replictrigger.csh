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
# This test should be kept in sync with trig2notrig, journaltrigger
#
# This test case exercises triggers in the context of replication.

# This test relies on the default region configuration, disable spanning regions
setenv gtm_test_spanreg 0

# prepare local and remote directories
$MULTISITE_REPLIC_PREPARE 2

unsetenv gtm_gvdupsetnoop
$gtm_tst/com/dbcreate.csh mumps 5

# start source and reciever
$MSR START INST1 INST2

# Begin trigger related updates
$gtm_exe/mumps -run replictrigger

# kill off any remaining ^fired GVNs
$gtm_exe/mumps -run cleanup^replictrigger

# need to verify the replicated journals and databases.
$MSR STOP INST1 INST2
$echoline
echo ""
$MSR RUN INST1 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst1_extracted_jnl_data.log
$MSR RUN INST2 '$gtm_tst/$tst/u_inref/jnl_extract.csh' > inst2_extracted_jnl_data.log
# the only diff should be the MSR header
diff inst1_extracted_jnl_data.log inst2_extracted_jnl_data.log | $grep -E '^(<|>)'
$echoline
cat inst1_extracted_jnl_data.log
$echoline
echo ""

$gtm_tst/com/dbcheck.csh -extract
