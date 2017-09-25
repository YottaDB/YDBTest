#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.                                          #
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test that source server started with an external filter followed by a deactivate and shutdown shuts down fine
#

echo "Create databases and start replication servers with an external filter on the source side"
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run ^extfilter"
$gtm_tst/com/dbcreate.csh mumps

echo "# Wait for the initial connection to be established"
setenv start_time `cat start_time`
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message "New History Content"

echo "# Deactivate source server"
$MUPIP replic -source -deactivate -rootprimary -instsecondary=$gtm_test_cur_sec_name

echo "# Wait for <Filter Stopped> message in source server log to signal deactivation is complete"
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message "Filter Stopped"

echo "# Shutdown replication servers. This used to cause SIG-11 in the passive source server previously."
$gtm_tst/com/dbcheck.csh
