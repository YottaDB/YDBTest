#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
setenv sub_test tpclue1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpclue1",! do ^tpclue1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpclue2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpclue2",! do ^tpclue2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpclue3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpclue3",! do ^tpclue3
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpclue4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpclue4",! do ^tpclue4
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpclue5
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpclue5",! do ^tpclue5
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

