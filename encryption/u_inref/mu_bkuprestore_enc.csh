#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv ydb_prompt 'GTM>'	# So can run the test under GTM or YDB and have same output
setenv ydb_msgprefix "GTM"	# So can run the test under GTM or YDB and have same output

# Test that BYTESTREAM BACKUPs created from unencrypted database (of either encryption-supporting GT.M versions or not) cannot be
# RESTOREd to a current GT.M version's encrypted database due to minor DB version mismatch.

# This test relies on database TN due to MUPIP BACKUP operation. So, don't mess with it.
setenv gtm_test_disable_randomdbtn
# Because the range of random versions includes those that support encryption, ensure that it is disabled.
setenv test_encryption NON_ENCRYPT
# Due to data corruption described in GTM-8351, disable random (V4) blocks.
setenv gtm_test_mupip_set_version DISABLE

$echoline
echo "Choose a random pre-encryption GT.M version"
$echoline
set prior_ver = `$gtm_tst/com/random_ver.csh -type dbminver_mismatch`
if ("$prior_ver" =~ "*-E-*") then
	echo "No prior versions available: $prior_ver"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
echo "$prior_ver" > priorver.txt

# Since this test switches to an older version (using "switch_gtm_version.csh"), we should disable use of V6 version in
# `dbcreate.csh` as it would otherwise get confusing. This is because the `dbcreate.csh` should happen using the prior
# version but would otherwise happen with the randomly chosen version in the env var `gtm_test_v6_dbcreate_rand_ver`.
setenv gtm_test_use_V6_DBs 0

echo "Random version choosen is - GTM_TEST_DEBUGINFO $prior_ver"
source $gtm_test/$tst_src/com/switch_gtm_version.csh $prior_ver $tst_image

echo
$echoline
echo "Switch to the prior version and create databases"
$echoline
echo
$gtm_test/$tst_src/com/dbcreate.csh mumps 1

echo
$echoline
echo "Some updates"
$echoline
$GTM << EOF
write "do in0^dbfill(""set"")",!  do in0^dbfill("set")
EOF

echo
$echoline
echo "Verify database integrity before BACKUP"
$echoline
$gtm_tst/com/dbcheck.csh

echo
$echoline
echo "Do BYTESTREAM BACKUP and redirect output to [backup.out]"
$echoline
$MUPIP backup -bytestream DEFAULT $prior_ver.dat >& backup.out

mkdir bak1 ; mv mumps.dat mumps.gld ./bak1	# To aid in debugging
mv $prior_ver.dat bak1/				# Since dbcreate below will rename. So move it away temporarily
echo
$echoline
echo "Switch to current GT.M version and create fresh encrypted databases"
$echoline
source $gtm_test/$tst_src/com/switch_gtm_version.csh $tst_ver $tst_image
# Now reenable encryption.
setenv test_encryption ENCRYPT
$gtm_test/$tst_src/com/dbcreate.csh mumps 1
mv bak1/$prior_ver.dat .
echo
$echoline
echo "Do MUPIP RESTORE from GTM_TEST_DEBUGINFO $prior_ver BACKUP to $tst_ver encrypted DATABASE"
$echoline
$MUPIP restore mumps.dat $prior_ver.dat
echo
$echoline
echo "Do dbcheck"
$echoline
$gtm_tst/com/dbcheck.csh
