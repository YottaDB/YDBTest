#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2011, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# D9L06-002816 op_gvrectarg should keep sgm_info_ptr and first_sgm_info in sync
#

setenv gtm_test_spanreg 0	# This test expects ^a and ^b to be mapped to different regions.
				# spanning the a global to two regions defeats the purpose of this test.

$gtm_tst/com/dbcreate.csh mumps 2
$gtm_exe/mumps -run d002816
$gtm_tst/com/dbcheck.csh
