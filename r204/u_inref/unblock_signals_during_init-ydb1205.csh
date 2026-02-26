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
#
# Test that signal initialization unblocks signals in a parent process signal mask
#
echo "## Copy the C and M programs that need to be tested"
cp $gtm_tst/$tst/inref/ydb1205.* .

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps
if ($status) then
	echo "# dbcreate.csh failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

echo
echo "## Test that signal initialization unblocks signals in a parent process signal mask"
echo

set file = ydb1205.c
set exefile = $file:r

foreach ver (V70005_R202 $tst_ver)
	echo "---> Running $exefile with YottaDB version $ver <---"
	source $gtm_tst/com/switch_gtm_version.csh $ver $tst_image
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile-$ver.map
	if (0 != $status) then
	        echo "LVNSET-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
	        continue
	endif
	rm ydb1205.o
	`pwd`/$exefile $ydb_dist/yottadb -run ydb1205
	echo "---> Finished $exefile with YottaDB version $ver <---"
	echo
end

echo "# Check database"
$gtm_tst/com/dbcheck.csh >>& dbcreate.out
