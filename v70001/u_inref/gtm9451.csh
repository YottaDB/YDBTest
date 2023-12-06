#################################################################
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
#
echo "#----------------------------------------------------------------------------------"
echo "# GTM-9451 - Verify LOCKSPACEFULL in final retry issues TPNOTACID and releases crit"
echo "#----------------------------------------------------------------------------------"
echo "# Release note pasted from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9451"
echo "#"
echo "# GT.M issues a TPNOTACID message and releases all database critical sections it owns during any LOCK operation"
echo "# in the final retry that could result in an indefinite hang, e.g. LOCKSPACE full. Previously, LOCK operations"
echo '# with a timeout less than $gtm_tpnotacidtime (or the default of 2 seconds), would not generate such an action.'
echo "# As a result, a process could hang in the final transaction processing retry. (GTM-9451)"
echo "#----------------------------------------------------------------------------------"

#
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps

set syslog_before1 = `date +"%b %e %H:%M:%S"`
echo "# Execute [mumps -run gtm9451] which will create lots of TP transactions with restarts and LOCKSPACEFULL scenario"
echo "# The fact that this command eventually returns automatically implies verification that the database critical section was"
echo "# released in the final retry as part of the LOCK command (or else the LOCK command would hang and not exit the process)."
echo "# Note: This step, when run with GT.M V7.0-000, would produce assert failures and SIG-11s thus proving this test works."
$gtm_dist/mumps -run gtm9451
set syslog_after1 = `date +"%b %e %H:%M:%S"`
$gtm_tst/com/getoper.csh "$syslog_before1" "" test_syslog.txt

echo "# Verify LOCKSPACEFULL message was seen in syslog"
set parentpid = `head -1 pidlist.txt`
$grep "\[$parentpid\]: %YDB-E-LOCKSPACEFULL.*`pwd`" test_syslog.txt

echo "# Verify at least one TPNOTACID message was seen in syslog by child pids"
# Skip first line in pidlist.txt as it is parent pid. The rest of lines are child pids. Hence the "tail -n +2" below.
set pidlist = `tail -n +2 pidlist.txt`
$grep -E `echo $pidlist | sed 's/ /|/g'` test_syslog.txt | grep TPNOTACID | head -1

echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
