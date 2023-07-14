#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
# Portions Copyright (c) Fidelity National			#
# Information Services, Inc. and/or its subsidiaries.		#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###################################
### instream.csh for jnl_crash test ###
### Layek:9/17/2001: Now test does not force journal switch since
### "C9A07-001552-Rework-journali..." fixes are in CMS
###################################
#
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
if($?test_replic) then
	echo "jnl_crash test runs as Non-Replication only!"
	exit
endif
if ($LFE != "E") then
	echo "jnl_crash test runs as Extended test only!"
	exit
endif

setenv subtest_list "crash_rec_for1 crash_rec_for2 crash_rec_back2 C9B11-001794"
setenv subtest_exclude_list ""

# filter out subtests that cannot pass with MM
if ("MM" == $acc_meth) then
	setenv subtest_exclude_list "$subtest_exclude_list crash_rec_back2 C9B11-001794"
endif

if (("CLANG" == "$gtm_test_yottadb_compiler") && ("dbg" == "$tst_image")) then
	# Disable below subtest because we have noticed it fails occasionally with assert failures only when YottaDB is built
	# with CLANG. The assert failures are all explainable considering this subtest does kill -9s. But what is puzzling is
	# that the test never fails when YottaDB is built with GCC. Until then, we disable this subtest only for CLANG builds
	# and only for Debug builds (as they are the only ones with asserts).
	setenv subtest_exclude_list "$subtest_exclude_list crash_rec_for1"
endif

echo "JNL CRASH test starts..."
$gtm_tst/com/submit_subtest.csh
echo "JNL CRASH test DONE."

#
##################################
###          END               ###
##################################
