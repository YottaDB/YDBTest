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
GTM-F229760 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-002_Release_Notes.html#GTM-F167609)

When using TLS configuration verify-mode option SSL_VERIFY_PEER, GT.M enables TLSv1.3 Post Handshake Authentication (PHA) for client connections. When using TLS configuration verify-mode options SSL_VERIFY_PEER and SSL_VERIFY_POST_HANDSHAKE, GT.M enables TLSv1.3 PHA for server connections. By itself, SSL_VERIFY_POST_HANDSHAKE does not enable PHA. Previously, GT.M did not support TLSv1.3's PHA capability. This could cause problems when connecting to some TLSv1.3 servers that require PHA. (GTM-F167609)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"

setenv gtm_test_tls TRUE
source $gtm_tst/com/set_tls_env.csh

$MULTISITE_REPLIC_PREPARE 2

$MULTISITE_REPLIC_ENV

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps 1  >& dbcreate.out
echo

echo "### Test TLS with Post Handshake Authentication (PHA)"
echo "## Confirm that a connection can be established without error when PHA is enabled with SSL SSL_VERIFY_POST_HANDSHAKE in the encryption configuration"
echo "## Previously:"
echo "## 1. With v70004-v71001 the TLS connection succeeds, but TLSCONNINFO is emitted by the Receiver Server"
echo "## 2. With v70003 the TLS connection fails, and TLSHANDSHAKE is emitted by the receiver"
echo "## See the first paragraph of the release note at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/716"
echo "## and the thread at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/716#note_2746268352"
echo "## for details on why the above behaviors are expected for the given versions."
echo "##"
echo "## Note that it is not straightforward to test whether PHA is actually enabled by the configuration setting, per the discussions at:"
echo "## + https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2473#note_2856994777"
echo "## + https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2473#note_2857481633"
echo "## + https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2473#note_3114015706"
echo
echo "# Set TLS configuration setting 'verify-mode' to SSL_VERIFY_PEER with SSL_VERIFY_POST_HANDSHAKE on the Receiver Server, INST2"
echo "# This is done on INST2 only since it is the 'server' as far as OpenSSL is concerned, and SSL_VERIFY_POST_HANDSHAKE only applies to the server role."
cp gtmcrypt.cfg gtmcrypt-bak.cfg
cp $SEC_SIDE/gtmcrypt.cfg $SEC_SIDE/gtmcryptINIT.cfg
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_POST_HANDSHAKE";' $SEC_SIDE/gtmcrypt.cfg
echo

echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
echo

echo "# Stop both replication instances"
$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh >& dbcheck.out
