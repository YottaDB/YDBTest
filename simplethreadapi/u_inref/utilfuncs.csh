#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019-2021 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# Test of Utility Functions in the SimpleThreadAPI"
#
echo "# Now run utilfuncs*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/utilfuncs*.c .
cp $gtm_tst/simpleapi/inref/utilfuncs.m .	# needed by utilfuncs4_ydb_ci_tab_open_and_ydb_ci_tab_switch.c
$gtm_tst/com/dbcreate.csh mumps >& create.txt
if ($status) then
	echo "# DB Create failed: "
	cat create.txt
endif

cat >> callin.tab << CALLIN_EOF
citabcreate:	void	citabcreate^utilfuncs(I:ydb_int_t)
citabtest:	void	citabtest^utilfuncs()
CALLIN_EOF

source $gtm_tst/com/is_libyottadb_asan_enabled.csh	# defines "gtm_test_libyottadb_asan_enabled" env var

foreach file (utilfuncs*.c)
	if (($file == "utilfuncs3_MT_STAPIFORKEXEC.c") && $gtm_test_libyottadb_asan_enabled) then
		# libyottadb.so was built with address sanitizer
		# utilfuncs3_MT_CALLINAFTERXIT.c tests the following.
		#	SimpleThreadAPI call in child process after fork() returns YDB_ERR_STAPIFORKEXEC error if exec() isn't used
		# This has been seen to hang with ASAN. Not yet clear what the cause is but the current suspicion is that
		# it is an ASAN limitation with this fancy test case use of fork/exec/threads.
		# Therefore we disable this particular test program in this case.
		continue
	endif
	echo ""
	echo " --> Running $file <---"
	set exefile = $file:r

	if ($file == "utilfuncs4_ydb_ci_tab_open_and_ydb_ci_tab_switch.c") then
		setenv GTMCI callin.tab
	endif

	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "UTILFUNCS-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	`pwd`/$exefile

	unsetenv GTMCI

	if ($file == "utilfuncs3_MT_CALLINAFTERXIT.c") then
		$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $gtm_tst/$tst/outref/utilfuncsthreadA.txt >&! CALLINAFTERXIT.txt
		echo "Expected Output:"
		cat CALLINAFTERXIT.txt
		@ i = 0
		foreach text (CALLINAFTERXIT_*)
			if (`diff $text CALLINAFTERXIT.txt` == "") then
				@ i++
			else
				echo "$text"
			endif
		end
		if ($i == 8) then
			echo "All $i Threads returned expected output"
		else
			@ s = 8 - $i
			echo "See $s above threads that did not return expected output"
		endif
	endif

	if ($file == "utilfuncs3_MT_STAPIFORKEXEC.c") then
		$tst_awk -f $gtm_tst/com/process.awk -f $gtm_tst/com/outref.awk $gtm_tst/$tst/outref/utilfuncsthreadB.txt >&! STAPIFORKEXEC.txt
		echo "Expected Output:"
		cat STAPIFORKEXEC.txt
		@ i = 0
		foreach text (STAPIFORKEXEC_*)
			if (`diff $text STAPIFORKEXEC.txt` == "") then
				@ i++
			else
				echo "$text"
			endif
		end
		if ($i == 8) then
			echo "All $i Threads returned expected output"
		else
			@ s = 8 - $i
			echo "See $s above threads that did not return expected output"
		endif
	endif

end
$gtm_tst/com/dbcheck.csh >& check.txt
if ($status) then
	echo "# DB Check failed: "
	cat check.txt
endif
