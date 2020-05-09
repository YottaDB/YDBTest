#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2020 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# The below test is heavily based on env_xlate.csh. It verifies that ydb_env_translate works
# when the function is called ydb_env_xlate instead of gtm_env_xlate

source $gtm_tst/com/unset_ydb_env_var.csh ydb_env_translate gtm_env_translate
setenv compile  "$gt_cc_compiler $gtt_cc_shl_options $gt_cc_option_debug -I$gtm_dist -I$gtm_tst/com"
setenv syslibs "-lc"
setenv link	"$gt_ld_shl_linker $gt_ld_shl_options"

$gtm_tst/com/ipcs -a > ipcs1.out
$gtm_tst/com/dbcreate.csh a
setenv gtmgbldir a.gld
if ($?gtm_env_translate || $?ydb_env_translate) then
	echo "ERROR. it should not be defined"
else
	echo "ydb_env_translate is not defined"
endif

echo  -n
$GTM << EOF
s ^GBL="THIS IS A"
h
EOF

mkdir datbak ; mv a.dat a.gld datbak/		# Since dbcreate below will rename. So move it away temporarily
$gtm_tst/com/dbcreate.csh b
setenv gtmgbldir b.gld
$GTM << EOF
s ^GBL="THIS IS B"
h
EOF

mv b.dat b.gld datbak/
$gtm_tst/com/dbcreate.csh mumps
setenv gtmgbldir mumps.gld
$GTM << EOF
s ^GBL="THIS IS MUMPS"
h
EOF

mv datbak/* .					# Move back the backed up files (to prevent dbcreate renaming them)

#Test ydb_env_translate using a ydb_env_xlate function
echo "#########################################################################################"
echo "Testing ydb_env_translate using a ydb_env_xlate function"
echo ""
setenv a `pwd`/a.gld
set xlate = "$tst_working_dir/libxlate${gt_ld_shl_suffix}"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_env_translate gtm_env_translate $xlate
echo "ydb_env_translate = "$xlate
$compile $gtm_tst/$tst/inref/ydb_env_xlate.c
$link ${gt_ld_option_output}libxlate${gt_ld_shl_suffix} ydb_env_xlate.o $syslibs >& link1.log
echo $status
$gtm_exe/mumps -run basic
$gtm_exe/mumps -run null^basic
$gtm_exe/mumps -run err1^basic
$gtm_exe/mumps -run err2^basic
$gtm_exe/mumps -run err3^basic
$gtm_exe/mumps -run err4^basic
$gtm_exe/mumps -run err5^basic
$gtm_exe/mumps -run err6^basic

#Test ydb_gbldir_translate functionality that translates $ZGBLDIR into a global directory
echo "#########################################################################################"
echo "Testing ydb_gbldir_translate functionality that translates ZGBLDIR into a global directory"
echo ""
set xlate = "$tst_working_dir/libxlategld${gt_ld_shl_suffix}"
setenv ydb_gbldir_translate $xlate
echo "ydb_gbldir_translate = "$xlate
$compile $gtm_tst/$tst/inref/ydb_gbldir_xlate.c
$link ${gt_ld_option_output}libxlategld${gt_ld_shl_suffix} ydb_gbldir_xlate.o $syslibs >& link1.log
echo $status
$gtm_exe/mumps -run zgbldir

echo "#####################################################################################"
$gtm_tst/com/dbcheck.csh a
$gtm_tst/com/dbcheck.csh b
$gtm_tst/com/dbcheck.csh mumps
