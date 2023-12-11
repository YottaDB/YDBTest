#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Turn off statshare related env var as it affects test output and is not considered worth the trouble to maintain
# the reference file with SUSPEND/ALLOW macros for STATSHARE and NON_STATSHARE
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

echo "# Test that a ZGBLDIRACC error is NOT issued when accessing the SimpleAPI while ydb_app_ensures_isolation is set"
echo "# to a non-null value but a global directory does not exist"
echo ""
echo "# Set ydb_app_ensures_isolation to a non-null value"
setenv ydb_app_ensures_isolation "test"
echo "ydb_app_ensures_isolation set to $ydb_app_ensures_isolation"
echo ""
echo "# Since no global directory is created, each call to the SimpleAPI/SimpleThreadAPI should return ZGBLDIRACC error"
echo ""
cp $gtm_tst/$tst/inref/ydb397*.c .
foreach file(ydb397*.c)
	echo "--> Running $file <---"
	set exefile = $file:r
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
	        echo "YDB397-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
        	continue
	endif
	rm $exefile.o
	`pwd`/$exefile
	echo ""

end
