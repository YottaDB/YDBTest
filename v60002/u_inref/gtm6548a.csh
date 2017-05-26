#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test JOB command functionality for various process parameters.

mkdir case1 case2 case3 case4
touch input.mji
touch case2/input.mji
touch case3/input.mji
touch case4/input.mji

$gtm_exe/mumps -run jobmumps

echo
if ((-f \*.mjo\*) || (-f \*.mje\*)) then
	echo "TEST-E-FAIL: Job command has created Std Output/Error files in working diretory of parent process."
else
	echo "TEST-E-SUCCESS: Standard Output and Error files are created at proper location in all test cases."
endif
