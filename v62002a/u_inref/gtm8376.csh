#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015 Fidelity National Information 		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# GTM-8376 [nars] SIG-11 in OP_GVRECTARG.C with V62FT19
#
unsetenv gtm_side_effects
unsetenv gtm_boolean
$gtm_tst/com/dbcreate.csh .
cp $gtm_tst/$tst/inref/gtm8376*.m .

foreach boolean (0 1 2)
	foreach side_effect (0 1 2)
		setenv gtm_boolean $boolean
		setenv gtm_side_effects $side_effect
		echo "--------------------------------------------------------------------------------------------"
		rm -f *.o
		foreach testcase (a b c d e f g)
			set subtest="gtm8376${testcase}"
			echo " --> Compiling $subtest.m : gtm_boolean = $boolean : gtm_side_effect = $side_effect. Output follows"
			$gtm_exe/mumps $subtest.m
			echo -n " --> Running $subtest : gtm_boolean = $boolean : gtm_side_effect = $side_effect : "
			$gtm_exe/mumps -run $subtest
		end
		echo ""
	end
end

unsetenv gtm_side_effects
unsetenv gtm_boolean
$gtm_tst/com/dbcheck.csh
