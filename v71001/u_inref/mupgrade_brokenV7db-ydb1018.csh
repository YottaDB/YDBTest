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
# Note that this test is similar to and partially derived from
# v71000/inplaceconv_V6toV7-gtmf13547.
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
YDB1018 - Test fix of rare MUPIP UPGRADE issue that can cause V7 database files with integrity errors
********************************************************************************************

Test fix that prevents assert failures like the following:

%YDB-F-ASSERT, Assert failed in /Distrib/YottaDB/V999_R203/sr_unix/mu_swap_root.c line 405 for expression ((0 == upg_mv_block) || (upg_mv_block <= free_blk_id))

The below test case is based on the discussion at https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_3048383000.

See the following threads for additional details:
1. https://gitlab.com/YottaDB/DB/YDB/-/issues/1018#note_2961097079
2. https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1813

CAT_EOF
echo

setenv gtm_test_use_V6_DBs 0  # Disable V6 mode DBs as this test already switches versions for its various test cases
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver
echo '# The below tests force the use of V6 mode to create DBs. This requires turning off ydb_test_4g_db_blks since'
echo '# V6 and V7 DBs are incompatible in that V6 cannot allocate unused space beyond the design-maximum total V6 block limit'
echo '# in anticipation of a V7 upgrade.'
setenv ydb_test_4g_db_blks 0
echo

echo "# Set version to: V6"
source $gtm_tst/com/switch_gtm_version.csh $gtm_test_v6_dbcreate_rand_ver $tst_image
set tnum = "T1"
setenv gtmgbldir $tnum.gld
echo "# Create V6 database files"
$gtm_tst/com/dbcreate.csh $tnum >& dbcreate.out
$gtm_dist/mumps -run GDE exit >&! gde$tnum.out
echo '# Run [$gtm_dist/mumps -run ydb1018]'
$gtm_dist/mumps -run ydb1018

echo "# Set version to: V7"
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
echo "# Upgrade the global directory $gtmgbldir : GDE exit"
$gtm_dist/mumps -run GDE exit >>&! gde$tnum.out
echo
echo '# Run [echo "yes" | $gtm_dist/mupip upgrade -reg DEFAULT]'
echo '# Expect the upgrade to complete successfully. Previously, the upgrade would not complete with the following output:'
echo "# 1. With DBG builds: '%YDB-F-ASSERT, Assert failed in ../sr_unix/mu_swap_root.c line 405 for expression ((0 == upg_mv_block) || (upg_mv_block <= free_blk_id))'"
echo "# 2. With PRO builds: '%YDB-E-MUNOFINISH, MUPIP unable to finish all requested actions' and the database will have integrity errors."
echo "yes" | $gtm_dist/mupip upgrade -reg DEFAULT

echo "# Run dbcheck.csh to ensure the database has no integrity errors"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
