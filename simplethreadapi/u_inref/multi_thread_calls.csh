#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

$gtm_tst/com/dbcreate.csh mumps

echo "# --------------------"
echo "# Test of YDB@a455fff6"
echo "# --------------------"
set file = "multi_thread_calls"
echo "# Compile $file.c (that does multi-threaded calls into ydb_tp_st() at same time) into binary $file"
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/$file.c
$gt_ld_linker $gt_ld_option_output $file $gt_ld_options_common $file.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $file.map

echo "# Run $file in background in a repeat loop 100 times"
echo "# Run 16 such sets of background loops to load the system"
echo "# Previously this used to cause a SIG-11."
echo "# We expect no output below as if there was a SIG-11, the test framework would have found core files and failed the test"
@ cnt = 16
while ($cnt > 0)
	(repeat 100 `pwd`/$file & ; echo $! > bg_$cnt.pid) >&! bg_$cnt.out
	@ cnt = $cnt - 1
end

echo "# Wait for backgrounded processes to finish"
@ cnt = 16
while ($cnt > 0)
	set bgpid = `cat bg_$cnt.pid`
	$gtm_tst/com/wait_for_proc_to_die.csh $bgpid
	@ cnt = $cnt - 1
end

$gtm_tst/com/dbcheck.csh
