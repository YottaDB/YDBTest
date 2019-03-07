#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC and/or its subsidiaries.	#
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
#
# --------------------------------------------------------------------------------------------------------------
# Tests for replication pipe compression changes
# --------------------------------------------------------------------------------------------------------------
# cmplvl_qual		Test CMPLVL qualifier
# mix_connections	Test that compression is a connection property and not a source server property.
#			The same source server sends uncompressed or compressed records depending on receiver.
# repltrans2big		Test that REPLTRANS2BIG error is issued by receiver server
# zlib_not_found	(obsolete) Test that LD_LIBRARY_PATH/LIBPATH control whether GT.M finds zlib library or not
# --------------------------------------------------------------------------------------------------------------
#
echo "replic_compress test starts..."
setenv subtest_list_common ""
setenv subtest_list_replic "cmplvl_qual mix_connections repltrans2big"
setenv subtest_list_non_replic ""
#
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
endif

# Platforms that do not have gtm versions without compression, disable the mixed connections test
# If the platform/host does not have prior GT.M versions, disable tests that require them
if ( (1 == $gtm_platform_no_compress_ver) || ($?gtm_test_nopriorgtmver) ) then
	setenv subtest_exclude_list "mix_connections"
else if ($?ydb_environment_init) then
	# In a YDB environment (i.e. non-GG setup), we do not have prior versions that are needed
	# by the below subtest. Therefore disable it.
	setenv subtest_exclude_list "mix_connections"
endif

$gtm_tst/com/submit_subtest.csh
echo "replic_compress test DONE."
