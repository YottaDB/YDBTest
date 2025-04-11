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
Test the following GitLab threads:
********************************************************************************************

Test the fix for reported failure in the overflow/jnlbuffer subtest where a MUUPGRDNRDY message was followed by a %GTM-I-TEXT, Iteration:1, Status Code:76 line in the MUPIP REORG -UPGRADE -REG BREG output. Details at:
https://gitlab.com/YottaDB/DB/YDB/-/issues/1027#note_2429352656

Test the fix for a formatting issue with MUPIP REORG -UPGRADE -DBG where global variable names in the output in contain unexpected control characters. Details at:
https://gitlab.com/YottaDB/DB/YDB/-/issues/1027#note_2427222223

CAT_EOF
echo

setenv gtm_test_use_V6_DBs 0  # Disable V6 mode DBs as this test already switches versions for its various test cases
echo '# The below tests force the use of V6 mode to create DBs. This requires turning off ydb_test_4g_db_blks since'
echo '# V6 and V7 DBs are incompatible in that V6 cannot allocate unused space beyond the design-maximum total V6 block limit'
echo '# in anticipation of a V7 upgrade.'
setenv ydb_test_4g_db_blks 0
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver
echo

echo "### Test 1: Test fix for 'Status Code:76' in MUPIP REORG -UPGRADE -REG BREG output"
echo "# Set version to V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 database"
setenv gtmgbldir T1.gld
echo "# Run M routine to set fill many nodes with a long subscript name"
$gtm_tst/com/dbcreate.csh T1 -key_size=472 -block_size=512 >& dbcreateT1.out
$gtm_dist/mumps -run %XCMD 'for i=1:1:4000 set ^abcdefgh($j(i,250))=i'

echo "# Set version to V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory"
$gtm_dist/mumps -run GDE exit >& gdeT1v7.out
echo "# Run first stage of upgrade process: MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg DEFAULT >& upgradeT1.out
echo "# Run second stage of upgrade process to produce the error condition: MUPIP REORG -UPGRADE -DBG"
yes | $gtm_dist/mupip reorg -upgrade -reg DEFAULT >& reorgT1.out
echo "# Confirm MUUPGRDNRDY and '%YDB-I-TEXT, Iteration:1, Status Code:76' errors did not occur during MUPIP REORG -UPGRADE."
echo "# Prior to commit https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1658/diffs?commit_id=cc906d04e01dd3dae6fca2213cfe51493a633b4e,"
echo "# such errors would appear in the below output."
cat reorgT1.out
echo

echo "### Test 2: Test fix for unexpected control characters in global names output by MUPIP REORG -UPGRADE -DBG"

echo "# Set version to V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
echo "# Create a V6 database"
setenv gtmgbldir T2.gld
$gtm_tst/com/dbcreate.csh T2 -record_size=100000 >& dbcreateT2.out
echo "# Run M routine to create a long Unicode string and fill nodes under ^aglobalvariable with the long string value"
$gtm_dist/mumps -run %XCMD 'set val=$$^ulongstr(80000) for i=1:1:20 set ^aglobalvariable(i,$job)=val'

echo "# Set version to V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
rm *.o
echo "# Upgrade the global directory"
$gtm_dist/mumps -run GDE exit >& gdeT2v7.out
echo "# Run first stage of upgrade process: MUPIP UPGRADE"
yes | $gtm_dist/mupip upgrade -reg DEFAULT >& upgradeT2.out
echo "# Run second stage of upgrade process with -DBG: MUPIP REORG -UPGRADE -DBG"
yes | $gtm_dist/mupip reorg -upgrade -reg DEFAULT -dbg >& reorgT2.out
echo "# Do not expect any output below. Prior to commit https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1659/diffs?commit_id=79994b8bbbc055447c8b20dc7c7ee803dccccb9e,"
echo "# lines with global names containing control characters would be emitted."
$grep aglobalvariable reorgT2.out | $grep -vE 'aglobalvariable$|aglobalvariable '
