#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE532295)

GT.M disables proactive block splitting by default as well as within a TP transaction. FIS made this change after observing that, under certain conditions, the setting could incur spurious restarts and split blocks which were not subject to contention. To enable the feature outside of transaction processing, use a MUPIP SET -PROBLKSPLIT=n, where n is the number of nodes at which GT.M considers based on the number of restarts whether to split a block in advance of its becoming full. Previously, starting in V7.0-001, the default threshold for a proactive block split was 5 nodes and the feature applied to TP as well as non-TP. The performance issue was only ever observed in testing and not reported by a customer; it was not associated with any correctness or integrity concerns. (GTM-DE532295)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv gtm_test_use_V6_DBs 0

echo "## Test 1: GT.M disables proactive block splitting by default"
echo "## Test the first test case described at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/677#note_2515082291"
echo "# Create database file"
setenv gtmgbldir T1.gld
$gtm_tst/com/dbcreate.csh T1 >&! dbcreate.out
echo "# Confirm proactive block splitting is disabled"
$gtm_dist/dse d -f -a |& grep Proactive | sed 's/.* Proactive/Proactive/;'
echo

echo "## Test 2: GT.M disables proactive block splitting inside TP transactions"
echo "## Test the second test case described at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/677#note_2515082291"
echo "# Create database file"
setenv gtmgbldir T2.gld
$gtm_tst/com/dbcreate.csh T2 >> dbcreate.out
echo "# Set -problksplit=1"
$MUPIP set -problksplit=1 -reg "*" >& mupip_set_1.out
echo "# Create a routine to update database nodes inside TP transactions"
cp $gtm_tst/v70002/inref/gtmf135414.m .
sed -i '20i\	tstart ()' gtmf135414.m
sed -i '22i\	tcommit' gtmf135414.m
echo "# Run the routine"
$gtm_dist/mumps -run split^gtmf135414
echo "# Confirm Data blocks is 1, indicating that PROBLKSPLIT is non-zero in the database file"
echo "# but proactive block splitting was nevertheless disabled."
$MUPIP integ -reg "*" |& grep "Data" | cut -b 1-21 | sed 's/$/    '1'/;'
echo

echo "## Test 3: Upgrading the database to V7.1-001 resets the Proactive Block Split value in the database file header to the default value of 0"
echo "## Test the test case described at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/677#note_2515117359"
echo "# Since proactive block splitting behavior varies with different versions, do not randomly choose older V6 version for dbcreate.csh."
echo "# Test proactive split behavior for current version being tested, i.e. V7."
echo "# Create database file using a version between V70002 and V71000"
$gtm_tst/com/random_ver.csh -gte V70002 -lt V71000 >&! prior_ver.txt
if (0 != $status) then
	echo "TEST-I-SKIP, No suitable prior versions available, skipping test."
	exit
else
	set prior_ver = `cat prior_ver.txt`
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
setenv gtmgbldir T3.gld
$gtm_tst/com/dbcreate.csh T3 >> dbcreate.out
echo "# Set -problksplit=10"
$MUPIP set -problksplit=10 -reg "*" >& mupip_set_10.out
echo "# Check that proactive block splitting is 10"
$gtm_dist/dse d -f -a |& grep Proactive | sed 's/.* Proactive/Proactive/;'
echo "# Switch back to the version under test, i.e. r2.03 or greater"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Check that proactive block splitting is 0, indicating that it was reset"
$gtm_dist/dse d -f -a |& grep Proactive | sed 's/.* Proactive/Proactive/;'

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
