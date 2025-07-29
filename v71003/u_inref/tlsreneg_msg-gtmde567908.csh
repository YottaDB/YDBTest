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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-DE567908 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE567908)

Because TLSv1.3 protocol connections do not implement renegotiation, the Receiver and Source Servers messaging report "renegotiation" and "key-update" for TLSv1.2 and TLSv1.3 connections respectively. Previously the Servers issued messages stating that renegotiation occurred for TLSv1.3 even though TLSv1.3 does not support renegotiation. (GTM-DE567908)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_test_tls13_plus 1
setenv gtm_test_tls_renegotiate 1

$MULTISITE_REPLIC_PREPARE 2

$MULTISITE_REPLIC_ENV

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps 1  >& dbcreate.out

echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
echo

echo "# Sleep for 1.5 minutes to wait for TLS renegotiation to occur (renegotiation interval 1 minute)"
sleep 90
echo

echo "# Stop both replication instances"
$MSR STOP INST1 INST2
echo

echo '# Confirm 'key-update' messages ARE issued by the receiver server: [grep key-update $SEC_SIDE/RCVR*.log]'
echo "# Previously these messages would not be emitted when using TLS 1.3."
grep key-update $SEC_SIDE/RCVR*.log
echo

echo '# Confirm "Received REPL_RENEG_COMPLETE message" messages are NOT issued by the receiver server: [grep "Received REPL_RENEG_COMPLETE message" $SEC_SIDE/RCVR*.log]'
echo "# Previously these messages would be incorrectly be emitted when using TLS 1.3, even though TLS 1.3 does not support renegotiation."
grep "Received REPL_RENEG_COMPLETE message" $SEC_SIDE/RCVR*.log
echo

echo '# Confirm NO message is issued declaring whether renegotiation supported or not: [grep -E "Secure Renegotiation .* supported" $SEC_SIDE/RCVR*.log]'
echo "# Previously, these messages would be incorrectly emitted when using TLS 1.3, even though TLS 1.3 never supports renegotiation."
grep -E "Secure Renegotiation .* supported" $SEC_SIDE/RCVR*.log

$gtm_tst/com/dbcheck.csh >& dbcheck.out
