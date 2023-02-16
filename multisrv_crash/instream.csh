#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo "Multiple server crash test starts ..."
#
# This test can only run with BG access method, so let's make sure that's what we have
source $gtm_tst/com/gtm_test_setbgaccess.csh
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # all subtests in this test do a failover and so disable -trigupdate

# Both the subtests in this test do a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
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
source $gtm_tst/com/set_crash_test.csh	# sets YDBTest and YDB-white-box env vars to indicate this is a crash test
setenv subtest_list "M_REORG_CRASH C9A07_001552"
# Now start test
$gtm_tst/com/submit_subtest.csh
echo "Multiple server crash test ends"
#
##################################
###          END               ###
##################################
