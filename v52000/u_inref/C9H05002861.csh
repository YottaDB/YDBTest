#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2007-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# C9H05-002861 BADCHAR in expression causes GTMASSERT in emit_code.c during compile in V52000"
echo "# Do test in M mode and UTF8 mode (randomly chosen by the framework)"
echo "# Due to the presence of YDB-W-LITNOGRAPH AND YDB-W-BADCHAR in UTF-8 mode for a lot of cases in the run below"
echo "# it is much simpler (to maintain) to have the entire output in two sections"
echo "# one for M mode and another for UTF-8 mode"
echo ""

cp $gtm_tst/$tst/inref/c002861_*.m .
foreach mode ("M" "UTF-8")
	echo "# ----------------------------------------------"
	echo "# Switching test to $mode mode"
	echo "# ----------------------------------------------"
	echo "# Running : mumps -run c002861"
	$switch_chset $mode
	$gtm_exe/mumps -run c002861
	rm *.o	# remove object code created by one iteration before next iteration starts (to avoid errors due to CHSET diff)
end
