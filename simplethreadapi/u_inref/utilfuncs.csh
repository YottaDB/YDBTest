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
echo "# Test of Utility Functions in the SimpleThreadAPI"
#
echo "# Now run utilfuncs*.c (all tests driven by a C routine)"
cp $gtm_tst/$tst/inref/utilfuncs*.c .
$gtm_tst/com/dbcreate.csh mumps >& create.txt
if ($status) then
	echo "# DB Create failed: "
	cat create.txt
endif

foreach file (utilfuncs*.c)
	echo ""
	echo " --> Running $file <---"
	set exefile = $file:r

	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $file
	$gt_ld_linker $gt_ld_option_output $exefile $gt_ld_options_common $exefile.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& $exefile.map
	if (0 != $status) then
		echo "UTILFUNCS-E-LINKFAIL : Linking $exefile failed. See $exefile.map for details"
		exit -1
	endif
	`pwd`/$exefile


	if ($file == "utilfuncs3_MT_CALLINAFTERXIT.c") then
		sed -n '41,71p' $gtm_tst/$tst/outref/utilfuncs.txt > CALLINAFTERXIT.txt
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
		sed -n '78,107p' $gtm_tst/$tst/outref/utilfuncs.txt > STAPIFORKEXEC.txt
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
