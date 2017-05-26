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

$gtm_exe/mumps $gtm_tst/com/dbfill.m
$gtm_exe/mumps $gtm_tst/com/pfill.m

setenv sub_test tpbasic
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 50 1024

$GTM << GTM_EOF
w "do ^tpbasic",!  do ^tpbasic
; the following commands should throw error VIEWNOTFOUND errors
view 1
view 0
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test tpatomic
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 500 1024
$GTM << GTM_EOF
w "do ^tpatomic",! do ^tpatomic
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

if ($LFE == "L") exit

setenv sub_test tphic
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 125 500 1024 500 1024
$GTM << GTM_EOF
w "do ^tphic",! do ^tphic
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test ixupd1
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 1024
$GTM << GTM_EOF
w "do ^ixupd1",! do ^ixupd1
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test largetp
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 64
$GTM << GTM_EOF
w "do ^largetp",! do ^largetp
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

setenv sub_test largetp2
setenv gtm_test_sprgde_id ${sub_test}	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate.csh mumps . 255 2040 2560 500 64
$GTM << GTM_EOF
w "do ^largetp2",! do ^largetp2
h
GTM_EOF
$gtm_tst/com/dbcheck.csh -extract
unsetenv sub_test

$grep "TEST FAILED" *.mjo*

ls *core* >& /dev/null
if ($status == 0) echo "Core found in $PWD"
echo "End of TP tests"
