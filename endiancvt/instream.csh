#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
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

# This test uses V4 versions in a lot of subtests. MM access method works well only from versions V5.3-002.
source $gtm_tst/com/gtm_test_setbgaccess.csh

# Large align size will have issues with 32 bit OS and the maximum align sizes vary across the GG servers
# So force the align_size to the testsystem default value i.e 4096.
setenv test_align 4096
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/align=[1-9][0-9]*/align='$test_align'/'`

echo "Endian Conversion tests starts..."
if !($?gtm_platform_no_V4) then
	setenv v4ver `$gtm_tst/com/random_ver.csh -type V4`
	if ( "$v4ver" =~ "*-E-*") then
		# This will cause the test to fail, but the subtests should all pass
		echo "There are no V4 versions. Dynamically setting gtm_platform_no_V4"
		setenv gtm_platform_no_V4 1
		echo "setenv gtm_platform_no_V4 1" >> settings.csh
	else
		setenv sv4 "source $gtm_tst/com/switch_gtm_version.csh $v4ver $tst_image"
	endif
endif
setenv sv5 "source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image"
#
setenv DBCERTIFY "$gtm_exe/dbcertify"
setenv MUPIPV5 "env gtm_dist=$gtm_exe $gtm_exe/mupip"

setenv subtest_list_non_replic ""
setenv subtest_list_replic     "basic transaction_nos non_native mixed_formats v4_database recycled_blocks C9H08002888 C9K06003281 eotf"
setenv subtest_list_common ""
#
######################################################
if ($?test_replic == 1) then
       setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
       setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif
setenv subtest_exclude_list ""
# on platforms that don't have a V4 version, disable the subtests that rely on V4 versions
if ( $?gtm_platform_no_V4) then
	setenv subtest_exclude_list "$subtest_exclude_list basic v4_database recycled_blocks"
endif
# The below subtest needs encryption
if ("NON_ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list eotf"
endif
# Filter out white box tests that cannot run in pro
if ("pro" == "$tst_image") then
	setenv subtest_exclude_list "$subtest_exclude_list eotf"
endif
$gtm_tst/com/submit_subtest.csh

unsetenv v4ver
echo "Endian Conversion tests ends"
