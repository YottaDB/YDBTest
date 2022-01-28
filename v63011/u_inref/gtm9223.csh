#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "----------------------------------------------------------------------------"
echo "# Test that opening a PIPE device does not close any open TLS socket devices"
echo "----------------------------------------------------------------------------"

# Setup SSL/TLS if not already set as this test relies on it.
if ("TRUE" != $gtm_test_tls) then
	setenv gtm_test_tls TRUE
	source $gtm_tst/com/set_tls_env.csh
endif

set portno = `source $gtm_tst/com/portno_acquire.csh`	# Allocate port number for TCP socket communication

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

echo '# Run [yottadb -run gtm9223 $portno]'
$ydb_dist/yottadb -run gtm9223 $portno

$gtm_tst/com/portno_release.csh	# Release the portno allocated above by portno_acquire.csh

echo "# Run dbcheck.csh at end"
$gtm_tst/com/dbcheck.csh

