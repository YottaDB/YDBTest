#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
#-------------------------------------------------------------------------------------

# errors				[karthikk]	Test various error scenarios.
# libconfig				[karthikk]	Test that both encryption and TLS configuration files can reside in the same file.
# gtmtlslib_cipherversion-gtmf167995	[jon]		Test the GT.M TLS plugin library exposes an external call interface providing cipher suite and version information

echo "tls test starts..."

# Setup SSL/TLS if not already set as this test relies on it.
if ("TRUE" != $gtm_test_tls) then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif
# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     ""
setenv subtest_list_non_replic ""
setenv subtest_list_non_replic "$subtest_list_non_replic gtmtlslib_cipherversion-gtmf167995"
setenv subtest_list_replic     ""
setenv subtest_list_replic     "$subtest_list_replic errors"
setenv subtest_list_replic     "$subtest_list_replic libconfig"

if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Use $subtest_exclude_list to remove subtests that are to be disabled on a particular host or OS
setenv subtest_exclude_list	""
if ("NON_ENCRYPT" == "$test_encryption") then
	setenv subtest_exclude_list "$subtest_exclude_list libconfig"
	setenv subtest_exclude_list "$subtest_exclude_list gtmtlslib_cipherversion-gtmf167995"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

echo "tls test DONE."
