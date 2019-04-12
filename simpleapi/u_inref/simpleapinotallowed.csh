#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test of YDB_ERR_SIMPLEAPINOTALLOWED error in the SimpleAPI"
#
echo "# Now run simpleapinotallowed*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/simpleapinotallowed*.c .
$gtm_tst/com/dbcreate.csh mumps >& create.txt
if ($status) then
	echo "# DB Create failed: "
	cat create.txt
endif

foreach file (simpleapinotallowed*.c)
	echo ""
	echo " --> Running $file <---"
	set exefile = $file:r

	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "$file-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	`pwd`/$exefile

	unsetenv GTMCI
end

# ydb_fork_n_core check
if ($tst_image == 'pro') then
	foreach file (core*)
		mv $file noprint.$file
	end
endif

$gtm_tst/com/dbcheck.csh >& check.txt
if ($status) then
	echo "# DB Check failed: "
	cat check.txt
endif
