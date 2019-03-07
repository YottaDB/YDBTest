#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test correct behavior of $gtm_autorelink_keeprtn
source $gtm_tst/$tst/u_inref/enable_autorelink_dirs.csh
$gtm_tst/com/dbcreate.csh mumps 1

cat > dummy.m << EOF
dummy ;
	quit
EOF

echo '# set gtm_autorelink_keeprtn to True - Expect "numvers:" in zshow "a" output to be 1'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_autorelink_keeprtn gtm_autorelink_keeprtn `$gtm_exe/mumps -run gen^randbool 1`
echo "# The value of gtm_autorelink_keeprtn : GTM_TEST_DEBUGINFO $gtm_autorelink_keeprtn"
$gtm_exe/mumps -run keeprtn >&! true_keeprtn.out
$tst_awk '/rtnname: dummy/ {print $8,$9}' true_keeprtn.out

echo '# set gtm_autorelink_keeprtn to False - Expect "numvers:" in zshow "a" output to be 0'
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_autorelink_keeprtn gtm_autorelink_keeprtn `$gtm_exe/mumps -run gen^randbool 0`
echo "# The value of gtm_autorelink_keeprtn : GTM_TEST_DEBUGINFO $gtm_autorelink_keeprtn"
$gtm_exe/mumps -run keeprtn >&! false_keeprtn.out
$tst_awk '/rtnname: dummy/ {print $8,$9}' false_keeprtn.out

echo '# unset gtm_autorelink_keeprtn - Expect "numvers:" in zshow "a" output to be 0'
source $gtm_tst/com/unset_ydb_env_var.csh ydb_autorelink_keeprtn gtm_autorelink_keeprtn
$gtm_exe/mumps -run keeprtn >&! unset_keeprtn.out
$tst_awk '/rtnname: dummy/ {print $8,$9}' unset_keeprtn.out

$gtm_tst/com/dbcheck.csh
