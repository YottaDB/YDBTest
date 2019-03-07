#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test of ydb_node_previous_st() function for Global amd Local variables in the SimpleThreadAPI
#

echo "# Test of ydb_node_previous_st() function for Global and Local variables in the SimpleThreadAPI"
cp $gtm_tst/$tst/inref/gvnlvnnodeprev*.c .
echo "# Now run gvnlvnnodeprev*.c (all tests driven by a C routine)"
foreach var_type (gvn lvn)

	foreach file (*"$var_type"*nodeprev*.c)
		echo ""
		if ($var_type == "gvn") then
			echo "---> Running $file:r for Global Variables <---"
		else
			echo "---> Running $file:r for Local Variables <---"
		endif
		set exefile = $file:r
		$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
		$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
		if (0 != $status) then
			echo "$var_type""NODEPREV-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
			exit -1
		endif
		$gtm_tst/com/dbcreate.csh mumps 1 -key_size=256 -null_subscripts=TRUE >>& dbcreate.out
		if ($status) then
			echo "DB Create failed, output below:"
			cat dbcreate.out
		endif

		if ($var_type == "gvn") then
			`pwd`/$exefile Global ^X ^Y ^B%dbasevarInvChar ^1namestartswithdigit ^Verylongbasevarthatexceedsmaxlength
		else
			`pwd`/$exefile Local X Y B%dbasevarInvChar 1namestartswithdigit Verylongbasevarthatexceedsmaxlength
		endif

		$gtm_tst/com/dbcheck.csh >>& dbcheck.out
		if ($status) then
			echo "DB Check failed, output below:"
			cat dbcheck.out
		endif

		$gtm_exe/mumps -run %XCMD 'kill ^X'
	end
end
