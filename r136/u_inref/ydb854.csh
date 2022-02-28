#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# ---------------------------------------------------------------------------------------------------------------'
echo '# Test that ICUSYMNOTFOUND error using Simple API does not assert fail'
echo '# This test script automates the ydb_init.sh script at https://gitlab.com/YottaDB/DB/YDB/-/issues/854#description'
echo '# with adjustments to use YDBTest conventions for compiling/linking Simple API C programs.'
echo '# ---------------------------------------------------------------------------------------------------------------'

set file = "ydb854"
echo "# Build $file executable"

$switch_chset "M"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map
if (0 != $status) then
	echo "TEST-E-LINKFAIL : Linking $file failed. See $file.map for details"
	exit 1
endif
$switch_chset "UTF-8"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_icu_version gtm_icu_version

echo "# Running $file executable"
echo "# Expect to see ICUSYMNOTFOUND error (used to see an assert failure in r1.34 Debug builds)"
`pwd`/$file

