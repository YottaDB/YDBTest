#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv sub_test rinttp1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 4096
$GTM << GTM_EOF
w "do ^rinttp(1)",! do ^rinttp(1)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test rinttp2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 4096
$GTM << GTM_EOF
w "do ^rinttp(2)",! do ^rinttp(2)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test rinttp3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps 9 125 1000 1024 500 4096
$GTM << GTM_EOF
w "do ^rinttp(3)",! do ^rinttp(3)
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

