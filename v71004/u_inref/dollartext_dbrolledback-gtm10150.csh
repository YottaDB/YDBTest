#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-10150 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE1959410150)

\$TEXT() recognizes and reports DBROLLEDBACK error. Previously \$TEXT() ignored and did not report DBROLLEDBACK errors. This was only seen in development environments and was never reported by a customer. (GTM-10150)

CAT_EOF
echo

# All of the below are what the online_rollback test sets for its subtests
setenv gtm_test_jnl "SETJNL"
setenv gtm_test_mupip_set_version "disable"	# ONLINE ROLLBACK cannot work with V4 format databases
source $gtm_tst/com/gtm_test_setbeforeimage.csh	# ROLLBACK needs before image journaling for backward recovery

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
$MSR STARTSRC INST1 INST2 RP >& startsrc.out

echo '# Install a trigger named gtm10150trig and do 1000 updates'
$gtm_dist/mumps -run init^gtm10150
echo

echo '# Stage 1 (a control) : $TEXT() of the trigger with no online rollback. Expect the first line of the trigger.'
$gtm_dist/mumps -run control^gtm10150
echo

echo '# Stage 2 : a process does an update, then MUPIP JOURNAL -ONLINE -ROLLBACK -BACKWARD -RESYNC=800 takes the'
echo '# database back by about 200 updates, and then the process does $TEXT() of the trigger, which has to read the'
echo '# trigger from the database file and so notices the online rollback.'
echo '# Before the fix : $TEXT() ignored the DBROLLEDBACK error and returned an empty string'
echo '# With the fix   : expect a DBROLLEDBACK error from $TEXT(), and $TEXT() to work after the error'
$gtm_dist/mumps -run test^gtm10150
echo

$MSR STOPSRC INST1 INST2 >& stopsrc.out
# dbcheck.csh also runs MUPIP INTEG on INST2, whose database has replication on. The instance file of INST2
# (mumps.repl) is created only when the receiver server of INST2 starts, which this subtest never does. When the
# test system sets gtm_custom_errors (for instance freeze), MUPIP INTEG attaches the journal pool of a replicated
# region, which needs the instance file, and so would fail with FTOKERR/ENO2. So unsetenv gtm_custom_errors.
# Unsetting gtm_repl_instance instead would also avoid the journal pool attach, but would change the environment of
# every dbcheck.csh step on INST1 as well, where the instance file exists, whereas unsetting gtm_custom_errors only
# turns off instance freeze for the check (com/dbcreate_base.csh and com/set_randomjnl.csh do the same).
unsetenv gtm_custom_errors
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
