#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# old version GLD file should work for a database which is of the version being tested.
# Globals should map to their correct datafiles in multiple region scenario in this database
#
setenv gtm_test_dbformat_version `$gtm_tst/com/random_ver.csh -type "gld_mismatch"`
if ("$gtm_test_dbformat_version" =~ "*-E-*") then
	echo "No prior versions available: $gtm_test_dbformat_version"
	exit -1
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_dbformat_version
source $gtm_tst/com/ydb_temporary_disable.csh
#
if (`expr $gtm_test_dbformat_version "<" "V53002"`) then
	# MM access method works well only from versions V5.3-002.
	source $gtm_tst/com/gtm_test_setbgaccess.csh
endif
setenv version_list "$gtm_test_dbformat_version"
echo "$version_list" > version_list.txt
$gtm_tst/com/check_versions.csh gld_switch gld_switch
