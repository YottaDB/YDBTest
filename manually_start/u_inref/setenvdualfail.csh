#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2007, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Following sets the environment variables for all dual_fail tests.
# All dual_fail subtests should source this file as the first line

setenv test_sleep_sec 90
setenv test_short_sleep_sec 15
setenv gtm_test_jobcnt 3
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally
#even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
# Following is to work around C9D07-002359 for debug versions
##DISABLED_TEST##REENABLE##
setenv tst_jnl_str "$tst_jnl_str,epoch=300"
##END_DISABLE##
setenv gtm_test_dbfill "IMPTP"
source $gtm_tst/com/set_crash_test.csh # sets YDBTest and YDB-white-box env vars to indicate this is a crash test
# use a tst_buffsize of 8MB for all dual fail tests, per C9D06-002314
setenv tst_buffsize 8388608

source $gtm_tst/com/gtm_test_trigupdate_disabled.csh   # this test does a failover and so disable -trigupdate

# this test does a failover. A->P won't work in this case.
if ("1" == "$test_replic_suppl_type") then
	source $gtm_tst/com/rand_suppl_type.csh 0 2
endif
# Since the receiver is explicitly restarted without -tlsid, the source server (if started with -tlsid) would error out with
# REPLNOTLS. To avoid that, allow for the source server to fallback to plaintext when that happens.
setenv gtm_test_plaintext_fallback

# Below is needed since the caller test does a "NO_IPCRM" and we do not want DBDANGER messages from freezing the instance
source $gtm_tst/com/adjust_custom_errors_for_no_ipcrm_test.csh

