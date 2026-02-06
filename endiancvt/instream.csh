#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ("ENCRYPT" == $test_encryption) then
	# As all the subtests will be transporting databases from one host to another host
	# do not point to the default library which differs across builds
	setenv gtm_crypt_plugin libgtmcrypt_${encryption_lib}_${encryption_algorithm}${gt_ld_shl_suffix}
	echo "setenv gtm_crypt_plugin $gtm_crypt_plugin"	>> settings.csh
	# use the same symmetric key for all the databases on all the hosts.
	setenv gtm_test_eotf_keys 2 # This is required for eotf subtest
	source $gtm_tst/com/create_sym_key_for_multihost_use.csh
endif
if (0 != $test_replic_mh_type) then
	setenv gtm_test_use_V6_DBs 0	# Disable V6 DB mode due to difficulties with remote systems having same V6 version to create DBs
endif

# Even though, most of the tests are run as -replic, replication is never setup and so mumps.repl is never created. If $gtm_custom_errors is defined
# then MUPIP opeartions done below will result in FTOKERR/ENO2 errors. So, unsetenv gtm_custom_errors for all the tests. There are a lot more tests
# where $gtm_custom_errors is randomized. So, this is not a huge loss of test coverage.
unsetenv gtm_custom_errors

# Large align size will have issues with 32 bit OS and the maximum align sizes vary across the GG servers
# So force the align_size to the testsystem default value i.e 4096.
setenv test_align 4096
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/align=[1-9][0-9]*/align='$test_align'/'`

echo "Endian Conversion tests starts..."
setenv sv5 "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
#
setenv DBCERTIFY "$gtm_exe/dbcertify"
setenv MUPIPV5 "env gtm_dist=$gtm_exe $gtm_exe/mupip"

setenv subtest_list_non_replic ""
setenv subtest_list_replic     "transaction_nos non_native mixed_formats C9H08002888 C9K06003281 eotf"
setenv subtest_list_common ""
#
######################################################
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
# The below subtest needs encryption
if ("NON_ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list eotf"
endif
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list eotf"
endif
$gtm_tst/com/submit_subtest.csh

echo "Endian Conversion tests ends"
