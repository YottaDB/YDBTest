#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020 YottaDB LLC and/or its subsidiaries.	#
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
echo "# Test that replication connection happens using TLS 1.3 if OpenSSL >= 1.1.1 and TLS 1.2 otherwise"
echo "--------------------------------------------------------------------------------------------------"

# Setup SSL/TLS if not already set as this test relies on it.
if ("TRUE" != $gtm_test_tls) then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif

echo "# Create databases and start replication with TLS enabled"
$gtm_tst/com/dbcreate.csh mumps

echo "# Wait for the initial connection to be established"
setenv start_time `cat start_time`
$gtm_tst/com/wait_for_log.csh -log SRC_${start_time}.log -message "New History Content"

echo "# Check TLS version used in connection from source server log."
echo "# Should be TLSv1.3 for OpenSSL >= 1.1.1 installations and TLSv1.2 otherwise"
grep "Protocol Version" SRC_${start_time}.log

echo "# Shutdown replication servers"
$gtm_tst/com/dbcheck.csh

