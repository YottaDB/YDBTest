#################################################################
#								#
#	Copyright 2002, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# this script verifies C9C02-001909

# this test induces errors so gensprgde.m will error out while trying to generate .sprgde files
# besides this test does not generate enough data anyways so no point testing spanning regions.
setenv gtm_test_spanreg 0

$gtm_tst/com/dbcreate.csh .
echo ""
echo "Will try various error messages"
echo ""
echo "========================================"
$gtm_exe/mumps -run errormes c1 < /dev/null
$gtm_exe/mumps -run errormes c2 < /dev/null
$gtm_exe/mumps -run errormes c3 < /dev/null
$gtm_exe/mumps -run errormes c4 < /dev/null
$gtm_exe/mumps -run errormes c5 < /dev/null
$gtm_exe/mumps -run errormes c6 < /dev/null
$gtm_exe/mumps -run errormes c7 < /dev/null
$gtm_exe/mumps -run errormes c8 < /dev/null
$gtm_exe/mumps -run errormes c9 < /dev/null
$gtm_exe/mumps -run errormes c10 < /dev/null
$gtm_exe/mumps -run errormes c11 < /dev/null
$gtm_exe/mumps -run errormes c12 < /dev/null
$gtm_exe/mumps -run errormes c13 < /dev/null
$gtm_exe/mumps -run errormes c14 < /dev/null
$gtm_exe/mumps -run errormes c15 < /dev/null
$gtm_exe/mumps -run errormes c16 < /dev/null
$gtm_exe/mumps -run errormes c17 < /dev/null
$gtm_exe/mumps -run errormes c18 < /dev/null
$gtm_exe/mumps -run errormes c19 < /dev/null
$gtm_exe/mumps -run errormes c20 < /dev/null
$gtm_exe/mumps -run errormes c21 < /dev/null
$gtm_exe/mumps -run errormes c22 < /dev/null
$gtm_exe/mumps -run errormes c23 < /dev/null
$gtm_exe/mumps -run errormes c24 < /dev/null
$gtm_exe/mumps -run errormes c25 < /dev/null
$gtm_exe/mumps -run errormes c26 < /dev/null
$gtm_exe/mumps -run errormes c27 < /dev/null
$gtm_exe/mumps -run errormes cg1 < /dev/null
$gtm_exe/mumps -run errormes cg2 < /dev/null
$gtm_exe/mumps -run errormes cg3 < /dev/null
$gtm_exe/mumps -run errormes cg4 < /dev/null
$gtm_exe/mumps -run errormes cg5 < /dev/null
$gtm_exe/mumps -run errormes cg6 < /dev/null
$gtm_exe/mumps -run errormes cg61 < /dev/null
$gtm_exe/mumps -run errormes cg62 < /dev/null
$gtm_exe/mumps -run errormes cg63 < /dev/null
$gtm_exe/mumps -run errormes cg64 < /dev/null
$gtm_exe/mumps -run errormes cg7 < /dev/null
$gtm_tst/com/dbcheck.csh
