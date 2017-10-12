#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# ------------------------------------------------------------------------------
# for bugs fixed in V52000/V52000A
# ------------------------------------------------------------------------------
# C9D08002387 [Narayanan] VERMISMATCH error should be reported ahead of FILEIDGBLSEC,DBIDMISMATCH error
# C9G12002813 [Narayanan] Pattern match fails with 2 unbounded patterns where 2nd lower bound is >= 9
# D9F10002572 [Narayanan] Issue with post-conditions in GT.M
# C9C05002003 [Narayanan] Set $PIECE/$EXTRACT give error if part of a compound SET statement
# D9H02002642 [Narayanan] PROFILE screen function keys do not work with GT.M V5.2 on AIX/Solaris/HPUX
# D9G12002636 [smw]       Avoid losing terminal input on mupip intrpt including direct mode
# C9B10001744 [Narayanan] $Order() can return wrong value if 2nd expr contains gvn
# C9B10001765 [Narayanan] $Order() can give bad result if 2nd arg is an extrinsic that manipulates 1st arg
# D9C08002197 [Narayanan] Multiple local array based extended references on left of SET causes ACCVIO
# C9G04002779 [Steve]     Socket devices now respond to MUPIP INTRPT
# C9H03002835 [Steve]     Test new socket device MOREREADTIME device parameter
# C9H04002856 [Narayanan] INVSVN error is accompanied by GTMASSERT (other fixes to regressions in D9F10002572)
# C9H05002861 [Narayanan] BADCHAR in expression causes GTMASSERT in emit_code.c during compile in V52000
# C9H03002827 [SteveJ]    Move initialization of instance file name to avoid bogus ERR_REPLINSTMISMTCH
# C9D08002392 [Narayanan] Online backup has integrity errors in case wcs_recover() runs concurrently
# D9H05002658 [Narayanan] SIG-11 in jnl_write at KTB (due to gvcst_zprevious memory corruption)
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V52000 test starts..."
setenv subtest_list_common " "
setenv subtest_list_replic "C9H03002827 "
setenv subtest_list_non_replic "C9D08002387 C9G12002813 D9F10002572 C9C05002003 C9B10001744 C9B10001765 D9C08002197 C9G04002779 "
setenv subtest_list_non_replic "$subtest_list_non_replic C9H03002835 C9H04002856 C9H05002861 C9D08002392 D9H05002658 "
if (("OSF1" != $HOSTOS) && ("OS/390" !=  $HOSTOS)) then
	# The following subtests use "expect" which is absent in Tru64 and z/OS therefore do not include them.
	setenv subtest_list_non_replic "$subtest_list_non_replic D9H02002642 D9G12002636 "
endif
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

setenv subtest_exclude_list ""
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
	setenv subtest_exclude_list "$subtest_exclude_list C9D08002387"
else if ($?ydb_environment_init) then
	# We are in a YDB environment (i.e. non-GG setup)
	# Disable C9D08002387 subtest until V63002 is available as it needs a version with VERMISMATCH abilities
	# and we currently only have V63000A_R100 and V63000A both of which are identical relative to VERMISMATCH.
	# And V63001A is unusable until T63001A is available.
	setenv subtest_exclude_list "$subtest_exclude_list C9D08002387"
endif

$gtm_tst/com/submit_subtest.csh
echo "V52000 test DONE."
