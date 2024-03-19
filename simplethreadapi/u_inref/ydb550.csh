#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps
$MUPIP set -problksplit=0 -reg "*" >& mupip_set_problksplit.out

foreach file ("ydb550" "ydb550b" "ydb550c")
	if ("ydb550" == $file) then
		echo "# $file.c : Test that a nested ydb_tp_st() rolls back correctly when the parent transaction commits"
		echo "----------------------------------------------------------------------------------------------------"
	else if ("ydb550b" == $file) then
		echo ""
		echo "# $file.c : Run multiple processes/threads for 10 seconds to ensure that YDB_TP_RESTART is handled correctly"
		echo "----------------------------------------------------------------------------------------------------------------"
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

	if ("ydb550" == $file) then
		foreach thread (1 2 3 4)
			echo "start Thread $thread"
			cat thread${thread}.out
			echo "end Thread $thread\n"
		end
	endif
end

$gtm_tst/com/dbcheck.csh
