#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Note that this test is derived from tls/errors
cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-DE556365 - Test the following release note
*****************************************************************

Release note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-DE556365) says:

The Receiver Server, configured to use TLS, continues waiting for new connections when a Source Server fails to establish a TLS session (e.g. misconfiguration). Previously, a Receiver Server configured for TLS but without -PLAINTEXTFALLBACK would exit with TLSCONVSOCK error message when it failed to establish a TLS session. (GTM-DE556365)
CAT_EOF
echo

setenv gtm_test_use_V6_DBs 0
# Update gtmcrypt file to misconfigure TLS for INST1 replication
$MULTISITE_REPLIC_PREPARE 2
$MULTISITE_REPLIC_ENV

echo "### Test that a replication receiving server issues a TLSCONVSOCK error and terminates when"
echo "### the source server terminates due to a TLS configuration error."
echo "### For more details, see the thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/687#note_3109611733"
echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps 3 >&! dbcreate.out
echo "# Revise INSTANCE2.key to point to non-existent key to force Receiver Server to fail to establish TLS connection"
$MSR RUN INST2 'sed -i "s/INSTANCE2.key/INSTANCE456.key/" gtmcrypt.cfg'
echo "# Start the source instance and receiving instance"
$MSR STARTSRC INST1 INST2 RP >&! STARTSRC_INST1_INST2.out
$MSR STARTRCV INST1 INST2 >&! STARTRCV_INST1_INST2.out
echo "# Wait for receiver server log file to show the TLSCONVSOCK error message"
$gtm_tst/com/wait_for_log.csh -log $SEC_SIDE/RCVR*.log -message "YDB-E-TLSCONVSOCK"
echo "# Confirm the receiver server terminates after issuing a TLSCONVSOCK error"
grep "Receiver Server PID" SRC_*.log | cut -f 2 -d '=' | tr -d '[:space:]' >& recv.pid
$gtm_tst/com/wait_for_proc_to_die.csh `cat recv.pid`
echo "# Stop the source instance"
$MSR STOPSRC INST1 INST2 >&! STOPSRC_INST1_INST2.out
echo "# Expect no 'Waiting for a connection' message after TLSCONVSOCK in the receiver server log. Previously, at least one such message would appear."
tail -n +`grep -n "YDB-E-TLSCONVSOCK" $SEC_SIDE/RCVR*.log | head -1 | cut -f 1 -d ':'` $SEC_SIDE/RCVR*.log | grep "Waiting for a connection"
if ($status) then
	echo "PASS: Receiver server stopped accepting connections after TLSCONVSOCK"
else
	echo "FAIL: Receiver server continued accepting connections after TLSCONVSOCK"
endif
echo "# Confirm only one TLSCONVSOCK error was generated."
echo "# Previously, the receiver server would continue waiting for connections and generate multiple TLSCONVSOCK errors."
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/RCVR*.log "YDB-E-TLSCONVSOCK"
echo "# Confirm only one 'YDB-I-TEXT, Private Key corresponding to TLSID' message was generated."
echo "# Previously, the receiver server would continue waiting for connections and generate multiple YDB-I-TEXT errors of this sort."
$gtm_tst/com/check_error_exist.csh $SEC_SIDE/RCVR*.log "YDB-I-TEXT"

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
# TEST-E-MULTISITE is expected in this case, since we expect a TLSCONVSOCK error above, which
# will cause the receiver server to shutdown, thus interfering with dbcheck.csh's attempt to also
# shut down the receiver server replication.
$gtm_tst/com/knownerror.csh dbcheck.out "TEST-E-MULTISITE"
