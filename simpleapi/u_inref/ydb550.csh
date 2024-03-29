#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

foreach file ("ydb550" "ydb550b" "ydb550c")
	if ("ydb550" == $file) then
		echo "# $file.c : Test that a nested ydb_tp_s() rolls back correctly when the parent transaction commits"
		echo "---------------------------------------------------------------------------------------------------"
	else if ("ydb550b" == $file) then
		echo ""
		echo "# $file.c : Run multiple processes for 10 seconds to ensure that YDB_TP_RESTART is handled correctly"
		echo "------------------------------------------------------------------------------------------------------"
	else if ("ydb550c" == $file) then
		echo ""
		echo "# $file.c : Test user callback function initiated YDB_TP_RESTART is handled correctly"
		echo "-----------------------------------------------------------------------------------------"
	endif
	#SETUP of the driver C file
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
	$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map

	# Run driver C
	`pwd`/$file
	if ("ydb550" == "$file") then
		# The reference file has Process P2 output first and Process P1 output next.
		# Hence the use of pid=2 first in the foreach loop below.
		foreach pid (2 1)
			cat proc$pid.out
		end
	endif
end

$gtm_tst/com/dbcheck.csh
