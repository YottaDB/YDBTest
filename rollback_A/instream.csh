#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#!/usr/local/bin/tcsh -f
#
# The original rollback test is split to make each test complete quicker
#################################################
# For all the journal tests that need rollbacks.
#################################################
# [Chunling] 	C9901000794
# [Chunling] 	full_qual
# [Chunling]	virtual_end
# [Chunling]	seqno_chk
# [Layek]    	D9D12002408 rollback lost transaction processing start logic has a problem
# [Layek] 	D9E02002426 csob issue of rollback GTMASSERT
# [Layek]    	C9E03-002539 source server fails to read non-tp logical record after align record
# [Layek] 	D9E04002440 rollback should handle gap in a journal file after a crash
# [Layek] 	D9E04002447 fetch resync should not GTMASSERT
#
echo "Part A of rollback test starts..."
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore.
source $gtm_tst/com/gtm_test_setbeforeimage.csh
if ("ENCRYPT" == "$test_encryption") then
	# This test has had RF_sync issues which showed the servers stuck in BF_encrypt() for a long time
	# Disabling BLOWFISHCFB since it seems to be a known issue with BLOWFISHCFB - Check <rf_sync_timeout_BF_encrypt>
	# It is easier to re-randomize than to check if gtm_crypt_plugin is set and if so check if it points to BLOWFISHCFB
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo BLOWFISHCFB
	echo "# Encryption algorithm re-randomized by the test"	>>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh	>>&! settings.csh
endif
#
setenv subtest_list "C9901000794 full_qual virtual_end seqno_chk D9D12002408 D9E02002426 C9E03002539"
setenv subtest_list "$subtest_list D9E04002440 D9E04002447"
#
$gtm_tst/com/submit_subtest.csh
#
echo "Part A of rollback test DONE."
