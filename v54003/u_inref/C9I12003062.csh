#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This test ensures that if ever the global directory and database have an out-of-sync values for access method, GT.M
# runtime works fine by honoring the value in the database.
# Even though this test is named with the online rollback TR#, this is only a minor part of the actual online rollback
# TR and the TR# is used for the want of a better name. The actual online rollback regression tests will be added to
# a separate test suite - online_rollback

setenv gtm_test_mupip_set_version "disable"	 # mupip set -acc=MM doesn't work with V4 databases. So, disable creating V4 formats
setenv tst_jnl_str "-journal=enable,on,nobefore" # mupip set -acc=MM doesn't work with BEFORE_IMAGE journaling. So, force NOBEFORE
setenv test_encryption "NON_ENCRYPT"		 # mupip set -acc=MM doesn't work with ENCRYPTION. So, disable encryption

$echoline
echo "Case 1 ==> Global directory has BG, but database has MM"
$echoline
$gtm_tst/com/dbcreate.csh mumps 1
$GDE change -segment DEFAULT -acc=BG >&! case1_gde_change.out
$GDE show |& $grep -E "BG|MM" | $grep mumps.dat

$echoline
echo "==> Set access method in database to MM"
$echoline
$MUPIP set -acc=MM -region DEFAULT
$DSE dump -file |& $grep "Access method"

# The original test failure showed up as an assert in op_tcommit which is the reason we need a TP transaction. But, for
# completeness, test it with both TP as well as Non-TP transaction.  But, we don't need any heavy weight testing as the issue is
# exposed by the very first set.
$echoline
echo "==> Do a TP transaction to ensure that the operation works fine."
$echoline
$gtm_exe/mumps -run %XCMD 'tstart ():serial  set ^a="A simple set"  tcommit'
$gtm_exe/mumps -run %XCMD 'zwrite ^a'	 # Verify that the update indeed happened

$echoline
echo "==> Do a Non-TP transaction to ensure that the operation works fine."
$echoline
$gtm_exe/mumps -run %XCMD 'set ^b="A simple non-tp set"'
$gtm_exe/mumps -run %XCMD 'zwrite ^b'	 # Verify that the update indeed happened

$gtm_tst/com/dbcheck.csh

# Move databases and global directories to aid in debugging.
$gtm_tst/com/backup_dbjnl.csh case1 "" mv

$echoline
echo "Case 2 ==> Global directory has MM, but database has BG"
$echoline
$gtm_tst/com/dbcreate.csh mumps 1
$GDE change -segment DEFAULT -acc=MM >&! case2_gde_change.out
$GDE show |& $grep -E "BG|MM" | $grep mumps.dat

$echoline
echo "==> Set access method in database to BG"
$echoline
$MUPIP set -acc=BG -region DEFAULT
$DSE dump -file |& $grep "Access method"

# Unlike case 1, the out-of-sync in case 2 showed up even without a TP transaction. But, for completeness, test it
# with both a TP as well as Non-TP transaction

$echoline
echo "==> Do a TP transaction to ensure that the operation works fine."
$echoline
$gtm_exe/mumps -run %XCMD 'tstart ():serial  set ^a="A simple set"  tcommit'
$gtm_exe/mumps -run %XCMD 'zwrite ^a'	 # Verify that the update indeed happened

$echoline
echo "==> Do a Non-TP transaction to ensure that the operation works fine."
$echoline
$gtm_exe/mumps -run %XCMD 'set ^b="A simple non-tp set"'
$gtm_exe/mumps -run %XCMD 'zwrite ^b'	 # Verify that the update indeed happened

$gtm_tst/com/dbcheck.csh
