#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
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
#
# ------------------------------------------------------------------------------
# for bugs fixed in V50000
# ------------------------------------------------------------------------------
# C9E11002655 [Narayanan] Large number of global variables created within TP transaction corrupts database
# C9E04002574 [Narayanan] cert_blk (database block certification) does not error out for a lot of cases
# D9E10002504 [Malli] TSTART in Direct mode fails if it specifies preserved locals
# D9E12002512 [Mohammad] DSE ADD -STAR gets SIGADRALN error
# D9E04002439 [Vinaya]    C-stack leaks if a local variable is passed by reference through indirection
# D9D12002412 [Layek] $t process is killed by system signal 11
# C9E11002670 [Layek] zlink with longer than valid M name prints junk
# D9E05002460 [Vinaya] Journal file leak in source server on a crash restart
# ------------------------------------------------------------------------------
#
# The first subtest to be included in subtest_list_replic below will necessitate
#	a) a change to suite.txt to enable the test to be run with replication
#	b) a change to outref.txt to handle replication as well as non-replication test runs using ##TEST_AWK macros
#
echo "V50000 test starts..."
setenv subtest_list_common " "
setenv subtest_list_replic "D9E05002460 "
setenv subtest_list_non_replic "C9E11002655 C9E04002574 D9E10002504 D9E12002512 D9E04002439 D9D12002412 C9E11002670 "
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
$gtm_tst/com/submit_subtest.csh
echo "V50000 test DONE."
