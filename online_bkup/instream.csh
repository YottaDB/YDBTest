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
#########################################
### instream.csh for online_bkup test ###
#########################################
#
# Encryprion cannot support access method MM, so explicitly running the test with NON_ENCRYPT when acc_meth is MM
if ("MM" == $acc_meth) then
        setenv test_encryption NON_ENCRYPT
endif
if ("ENCRYPT" == "$test_encryption") then
	# This test has had RF_sync issues which showed the servers stuck in BF_encrypt() for a long time
	# Disabling BLOWFISHCFB since it seems to be a known issue with BLOWFISHCFB - Check <mrep-signature-name>
	# It is easier to re-randomize than to check if gtm_crypt_plugin is set and if so check if it points to BLOWFISHCFB
	unsetenv gtm_crypt_plugin
	setenv gtm_test_exclude_encralgo BLOWFISHCFB
	echo "# Encryption algorithm re-randomized by the test"	>>&! settings.csh
	source $gtm_tst/com/set_encryption_lib_and_algo.csh	>>&! settings.csh
endif
echo "ONLINE BACKUP test Starts..."
if ($LFE == "L") then
	setenv subtest_list "online1 online3 online5 online6"
else
	setenv subtest_list "online1 online3 online5 online6 online2 online4"
endif
$gtm_tst/com/submit_subtest.csh
echo "ONLINE BACKUP test DONE."
#
##################################
###          END               ###
##################################
