#!/usr/local/bin/tcsh -f
#################################################################
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
# Script to set gtm_test_use_V6_DBs to 1 and to run com/ydb_prior_version_check.csh on whatever
# the randomly selected version to use is (kept in $gtm_test_v6_dbcreate_rand_ver). This should be
# used in all tests that need to enable V6 DBs in the test itself overriding whatever random
# selections were made.
#
# Enable use of V6 DBs in the test
setenv gtm_test_use_V6_DBs 1
#
# Run com/ydb_prior_ver_check.csh to set up things for this version (though this is NOT the version
# we are running the test with - this is just for DB creation).
source $gtm_tst/com/ydb_prior_ver_check.csh $gtm_test_v6_dbcreate_rand_ver
#
# If V63003A_R120, the invocation above of ydb_prior_ver_check.csh would have set ydb_msgprefix to
# "GTM" but since we aren't switching version right now, go ahead and reverse it so it doesn't cause
# problems for us creating messages with the wrong prefix.
if ("V63003A_R120" == "$gtm_test_v6_dbcreate_rand_ver") then
	# This version required a msgprefix of GTM for GDE to work at all - time to revert it.
	unsetenv ydb_msgprefix
endif
