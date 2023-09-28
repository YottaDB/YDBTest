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
# This script is used in com/dbcreate_base.csh to reset the running version to the original one
# the test was started with. We had reset the version to an earlier V6* version to create the
# V6 databases. We need to revert the YDB/GTM version when com/dbcreate_base.csh returns. We also
# take the opportunity to revert ydb_msgprefix.
#
if ("V63003A_R120" == "$gtm_test_v6_dbcreate_rand_ver") then
	# This version required a msgprefix of GTM for GDE to work at all - time to revert it.
	unsetenv ydb_msgprefix
endif
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image # Restore test version
