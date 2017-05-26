#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test of miscellaneous scenarios involving alias variables/containers

set testlist = "quitalsinv alsopunwind1 alsopunwind2 alsrefcnt1 alsrefcnt2"

foreach testcase ($testlist)
	echo ""
	echo "-------------------------------------------------------"
	echo "--> Running : mumps -run $testcase"
	echo "-------------------------------------------------------"
	$gtm_exe/mumps -run $testcase
end
