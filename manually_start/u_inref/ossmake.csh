#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2011-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Set chset to M mode since the build manually flips to UTF-8 mode
$switch_chset M >&! switch_chset.out

# Disable gtmcompile, including the -dynamic_literals qualifer, since it confuses the MUMPS routines used to compile GT.M
unsetenv gtmcompile

set zver = `$gtm_dist/mumps -run %XCMD 'write $piece($zversion," ",2)'`

# execute the build
$echoline
echo "GTM_TEST_DEBUGINFO: Building GT.M Version : $zver"
$gtm_tst/$tst/u_inref/makebuild.csh $zver >&! fullbuild.log
if ($status) then
	$tail fullbuild.log
endif
$tst_awk '/Using/{print "GTM_TEST_DEBUGINFO:"$0;exit}' fullbuild.log

# Verify each newly built GT.M
foreach bld (pro dbg)
	echo "Testing $bld"
	$gtm_tst/$tst/u_inref/testbuild.csh $bld
	$gtm_tst/$tst/u_inref/testbuild.csh $bld "utf8"
end
$echoline
