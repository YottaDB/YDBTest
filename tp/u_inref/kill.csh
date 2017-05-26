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
setenv sub_test tpkill1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill1",! do ^tpkill1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill2",! do ^tpkill2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill3
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill3",! do ^tpkill3
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill4
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill4",! do ^tpkill4
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill5
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill5",! do ^tpkill5
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill6
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill6",! do ^tpkill6
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkill7
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkill7",! do ^tpkill7
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkilla
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkilla",! do ^tpkilla
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkillb
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkillb",! do ^tpkillb
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkillc
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkillc",! do ^tpkillc
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkilld
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkilld",! do ^tpkilld
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkille
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkille",! do ^tpkille
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkillf
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkillf",! do ^tpkillf
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkillg
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkillg",! do ^tpkillg
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpkillh
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 50 1024
$GTM << GTM_EOF
w "do ^tpkillh",! do ^tpkillh
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test
