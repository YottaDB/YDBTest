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
#
#

echo '# New simplethreadapi/errstrTest subtest to test errstr parameter of SimpleThreadAPI similar to the go/unit_tests/key_t_test.go/TestKeyTSetWithDifferentErrors() test'
echo '# 20 threads concurrently cause GVUNDEF and INVSTRLEN errors and check that errstr is correctly set each time in both cases'
echo '# There should be no output unless the test fails'

#SETUP of the driver C file
$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$tst/inref/errstrTest.c
$gt_ld_linker $gt_ld_option_output errstrTest $gt_ld_options_common errstrTest.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& errstrTest.map

$gtm_tst/com/dbcreate.csh mumps

# Run driver C
`pwd`/errstrTest

$gtm_tst/com/dbcheck.csh
