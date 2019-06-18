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
# Test of various SimpleAPI commands in multiple threads similar to the go/randomWalk subtest
#
#
unsetenv gtmdbglvl   # Disable storage debugging as that can turn this 1 minute job into an hour

echo '# Test of various SimpleThreadAPI commands in multiple threads similar to the go/randomWalk subtest'

#SETUP of the driver C file
# if this system is armv7l set a flag that reduces the number of threads the test creates
if (`uname -m` == "armv7l" || `uname -m` == "armv6l") then
	set ISARM = "-DISARM=1"
else
	set ISARM = ""
endif
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/randomWalk.c $ISARM
$gt_ld_linker $gt_ld_option_output randomWalk $gt_ld_options_common randomWalk.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& randomWalk.map

$gtm_tst/com/dbcreate.csh mumps

# Run driver C
`pwd`/randomWalk

$gtm_tst/com/dbcheck.csh
