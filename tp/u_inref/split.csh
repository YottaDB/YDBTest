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
#
setenv sub_test dzsplit1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit1",! do ^dzsplit1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit2",! do ^dzsplit2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit3",! do ^dzsplit3
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 1000 1024 500 1024
$GTM << GTM_EOF
w "do ^dzsplit4",! do ^dzsplit4
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit5
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit5",! do ^dzsplit5
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit6
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit6",! do ^dzsplit6
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test dzsplit7
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^dzsplit7",! do ^dzsplit7
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixsplit
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixsplit",! do ^ixsplit
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixsplit1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixsplit1",! do ^ixsplit1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixsplit2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixsplit2",! do ^ixsplit2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixsplit3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixsplit3",! do ^ixsplit3
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixsplit4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixsplit4",! do ^ixsplit4
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test
