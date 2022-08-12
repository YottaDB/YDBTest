#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "--------------------------------------------------------------------------------------------------"
echo "# Test that replication servers restart after TLS connection issues (issues via white-box test)"
echo "--------------------------------------------------------------------------------------------------"

# Setup SSL/TLS if not already set as this test relies on it.
if ("TRUE" != $gtm_test_tls) then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif

# Set up white box test - since this applies to the server processes this will start, set these before create DBs
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 169 # WBTEST_REPL_TLS_RECONN
#
# In this white box test, the internal test case counter (gtm_wbox_input_test_case_count) is important as it delays
# when the connection drop happens. If it happens too early in communications (during initialization), the test
# isn't expecting that so the white box test gets ignored. The internal counter is incremented on each call to
# repl_recv() in the GTM_WHITE_BOX_TEST() macro there and when that counter matches the test case count below, the
# artificial connection drop is initiated on the call to gtm_tls_recv().
#
# To discover the best value for gtm_white_box_test_case_count, trace code was added to the GTM_WHITE_BOX_TEST()
# macro and tracing when the internal count was incremented and noting in the receiver server log that the internal
# counter was over 8 before we ever called any gtm_tls_recv() which is where the white box code get activated from.
# Since the code in repl_recv() sets the internal counter to 11 "to avoid further invocations of the white box test",
# we tried 10, and it worked.
#
setenv gtm_white_box_test_case_count 10
echo
echo "# Create databases and start replication with TLS enabled"
$gtm_tst/com/dbcreate.csh mumps
echo
echo "# Wait for the initial connection to be established"
setenv start_time `cat start_time`
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR_${start_time}.log -message "New History Content"
echo
echo "# Add some records forcing a reconnection when the test case counter is met"
# Note the number of records is large-ish to give the replication servers enough work to give the connection time
# to drop AND be reinstated before things shutdown
$GTM <<EOF
    for i=1:1:10000 set ^a(i*2)=\$justify(\$job,75)
EOF
echo "# Shutdown replication servers"
$gtm_tst/com/dbcheck.csh
echo
echo "# Validate that the receiver server dropped connection and restarted - messages follow:"
$gtm_dist/mumps -run verify^gtm7987 "$SEC_SIDE/RCVR_${start_time}.log"

