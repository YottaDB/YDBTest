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
GTM-F248691 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F248691)

GT.M Database Replication implements Post Handshake Authentication (PHA) when using TLSv1.3. Previously, GT.M Replication ignored the SSL_VERIFY_POST_HANDSHAKE verification mode, rejected, or in V7.0-004 through V7.1-001, incorrectly applied it. To negotiate a TLS connection using PHA, the configured TLS ID must specify SSL_VERIFY_PEER and SSL_VERIFY_POST_HANDSHAKE in the verify-mode. Using other SSL_VERIFY_* options without SSL_VERIFY_PEER results in an error, either TLSINIT at server startup or TLSCONVSOCK when the Server reads the TLS configuration for its TLSID. While GT.M versions V7.0-004 through V7.1-001 do not support SSL_VERIFY_POST_HANDSHAKE, they do not reject it. Receiver Servers from V7.0-004 through V7.1-001, when configured with SSL_VERIFY_POST_HANDSHAKE, issue TLSCONNINFO messages because the Receiver Server fails to request the peer certificate. This happens whether or not the configuration for the Source Server specifies PHA. Receiver Servers configured with SSL_VERIFY_FAIL_IF_NO_PEER_CERT fail to connect in this situation.

This change adds two new configuration options to the TLS configuration file: "post-handshake-fallback" and "plaintext-fallback" which each take an integer value. Any positive integer value enables the configuration. GT.M applies these configuration options only to GT.M replication Servers and ignores them for SOCKET devices because these options are part of the replication protocol. Applications using SOCKET devices can imitate either fallback option by checking \$DEVICE for the TLS connection failure reason and reacting appropriately. Please see the GT.M Programmer's Guide section about WRITE /TLS for more information.

"plaintext-fallback" option sets a default action, which can be overridden by the MUPIP command line option -[no]plaintextfallback, to disallow or allow the servers to fallback to plaintext when they fail to negotiate a TLS connection

"post-handshake-fallback" enables Receiver Servers configured with SSL_VERIFY_POST_HANDSHAKE to temporarily drop SSL_VERIFY_POST_HANDSHAKE when a TLS handshake (TLSHANDSHAKE) with the Source Server fails due to missing support for SSL_VERIFY_POST_HANDSHAKE. After the next successful connection, the Receiver Server restores SSL_VERIFY_POST_HANDSHAKE for subsequent connections. This allows misconfigured peers, including prior versions, to establish a connection while the Receiver Server periodically issues a warning message.

The OpenSSL project documentation states that client mode connections should only use SSL_VERIFY_PEER and no other option. The GT.M reference TLS plugin ignores all verify-mode options except SSL_VERIFY_PEER to avoid any unintended operation for client mode connections. GT.M does this to allow sharing of configuration between both client mode TLS processes and server mode TLS processes. (GTM-F248691)

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

echo "### Test 1: TLS with Post Handshake Authentication (PHA)"
echo "## Basic case. Confirm that PHA can successfully be enabled with SSL_VERIFY_POST_HANDSHAKE,"
echo "## and a connection can be established without error."
echo "## Previously:"
echo "## 1. With v70004-v71001 the TLS connection succeeds, but TLSCONNINFO be emitted by the Receiver Server"
echo "## 2. With v70003 the TLS connection fails, and TLSHANDSHAKE is emitted by the receiver"
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
echo

echo "### Test 2: TLS with Post Handshake Authentication (PHA) and Receiver server with SSL_VERIFY_FAIL_IF_NO_PEER_CERT"
echo "## Expect TLS connection to succeed without errors."
echo "## Previously, TLS connection failed with TLSCONNINFO message when run against GT.M versions v70004-v71001."
cp $SEC_SIDE/gtmcrypt.cfg $SEC_SIDE/gtmcryptT1.cfg
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_POST_HANDSHAKE:SSL_VERIFY_FAIL_IF_NO_PEER_CERT";' $SEC_SIDE/gtmcrypt.cfg
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
echo

echo "### Test 3: TLS with PHA and 'post-handshake-fallback' configuration setting enabled, but Source Server does not support PHA"
echo "## Expect the Receiver Server to report that the Source Server did not send the PHA extension, issue a"
echo "## TLSHANDSHAKE warning, and temporarily drop SSL_VERIFY_POST_HANDSHAKE for the next connection attempt."
echo "## After the next successful connection the Receiver Server restores SSL_VERIFY_POST_HANDSHAKE, so the"
echo "## fallback fires again on the connection after that."
echo

echo "# Restore the initial Receiver Server (INST2) config, so Test 2's SSL_VERIFY_FAIL_IF_NO_PEER_CERT is not inherited"
cp $SEC_SIDE/gtmcrypt.cfg $SEC_SIDE/gtmcryptT2.cfg
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg

echo "# Receiver Server (INST2): require PHA, and enable 'post-handshake-fallback'"
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_POST_HANDSHAKE";' $SEC_SIDE/gtmcrypt.cfg
sed -i '/^.*INSTANCE2: {/a\		post-handshake-fallback: 1;' $SEC_SIDE/gtmcrypt.cfg

echo "# Source Server (INST1): SSL_VERIFY_NONE, so the reference plugin never calls SSL_set_post_handshake_auth()"
echo "# and the Source Server does not send the PHA extension in its CLIENT_HELLO. To the Receiver Server this is"
echo "# indistinguishable from a peer without PHA support, which the release note covers: the fallback 'allows"
echo "# misconfigured peers, including prior versions, to establish a connection'."
cp gtmcrypt.cfg gtmcryptT2src.cfg
sed -i '/^.*INSTANCE1: {/a\		verify-mode: "SSL_VERIFY_NONE";' gtmcrypt.cfg
echo

# The Source Server reconnects on its own after the Receiver Server drops the connection, so the number of
# connection attempts, and hence the number of TLSHANDSHAKE warnings, is timing dependent. Wait on an occurrence
# count in the Receiver Server log for each expected event rather than assuming one connection per Source Server
# start, and keep the counts, rather than the log lines themselves, out of the output below.
echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t3_srclogs = "SRC_${time_src}.log"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t3_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the first post-handshake fallback"
$gtm_tst/com/wait_for_log.csh -log $t3_rcvrlog -message "Post-handshake fallback enabled" -count 1 -duration 120
echo "# Stop source replication instance"
$MSR STOP INST1

echo "# Start source replication instance. SSL_VERIFY_POST_HANDSHAKE is temporarily dropped, so expect this connection to succeed"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t3_srclogs = "$t3_srclogs SRC_${time_src}.log"
$gtm_tst/com/wait_for_log.csh -log $t3_rcvrlog -message "Secure communication enabled using TLS/SSL protocol" -count 1 -duration 120
echo "# Stop source replication instance"
$MSR STOP INST1
echo

echo "# Start source replication instance. SSL_VERIFY_POST_HANDSHAKE was restored after the successful connection"
echo "# above, so expect the fallback to fire a second time"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t3_srclogs = "$t3_srclogs SRC_${time_src}.log"
$gtm_tst/com/wait_for_log.csh -log $t3_rcvrlog -message "Post-handshake fallback enabled" -count 2 -duration 120
echo "# Stop source replication instance"
$MSR STOP INST1

echo "# Start source replication instance once more"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t3_srclogs = "$t3_srclogs SRC_${time_src}.log"

echo "# Stop both replication instances"
$MSR STOP INST1 INST2
echo

# Collect the counts up front. grep -c always prints a number, but only if the file exists, so guard the
# backquotes rather than letting an absent log turn the comparisons below into tcsh syntax errors.
if (-e $t3_rcvrlog) then
	set t3_phafail_cnt = `$grep -c "Post-handshake authentication failure" $t3_rcvrlog`
	set t3_warning_cnt = `$grep -c "GTM-W-TLSHANDSHAKE" $t3_rcvrlog`
	set t3_fallback_cnt = `$grep -c "Post-handshake fallback enabled" $t3_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t3_phafail_cnt = 0
	set t3_warning_cnt = 0
	set t3_fallback_cnt = 0
endif

echo "# Confirm the Receiver Server reported that the Source Server did not send the PHA extension"
if (0 < $t3_phafail_cnt) then
	echo "TEST-I-PASSED Receiver Server reported a post-handshake authentication failure"
else
	echo "TEST-E-FAILED Receiver Server did not report a post-handshake authentication failure"
endif

echo "# Confirm the Receiver Server issued TLSHANDSHAKE as a warning, not as an error, because the fallback is enabled"
if (0 < $t3_warning_cnt) then
	echo "TEST-I-PASSED Receiver Server issued %GTM-W-TLSHANDSHAKE"
else
	echo "TEST-E-FAILED Receiver Server did not issue %GTM-W-TLSHANDSHAKE"
endif

echo "# Confirm the fallback fired at least twice. The Source Server configuration never changed across the"
echo "# connections above, so a second fallback means the Receiver Server restored SSL_VERIFY_POST_HANDSHAKE"
echo "# after the successful connection in between."
if (2 <= $t3_fallback_cnt) then
	echo "TEST-I-PASSED Receiver Server fell back at least twice, so it restored SSL_VERIFY_POST_HANDSHAKE"
else
	echo "TEST-E-FAILED Expected at least 2 post-handshake fallback messages, found $t3_fallback_cnt"
endif
echo

# The Receiver Server log holds the %GTM-W-TLSHANDSHAKE warnings this test expects, and the Source Server logs hold
# whatever the Source Server reported when the Receiver Server dropped the connection, which varies with timing.
# Rename them to .logx, the same mechanism check_error_exist.csh uses, to keep the error scanner from flagging them.
if (-e $t3_rcvrlog) mv $t3_rcvrlog ${t3_rcvrlog}x
foreach t3_srclog ($t3_srclogs)
	if (-e $t3_srclog) mv $t3_srclog ${t3_srclog}x
end

echo "### Test 4: TLS with PHA and 'post-handshake-fallback' disabled, and Source Server does not support PHA"
echo "## The counterpart to Test 3. With the fallback disabled the Receiver Server keeps SSL_VERIFY_POST_HANDSHAKE"
echo "## instead of temporarily dropping it, so expect TLSHANDSHAKE at error severity rather than as a warning,"
echo "## no fallback message, and no connection ever succeeding."
echo

echo "# Restore both configs to their initial state"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Receiver Server (INST2): require PHA, but do not enable 'post-handshake-fallback'"
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_POST_HANDSHAKE";' $SEC_SIDE/gtmcrypt.cfg

echo "# Source Server (INST1): SSL_VERIFY_NONE, so it does not send the PHA extension, as in Test 3"
sed -i '/^.*INSTANCE1: {/a\		verify-mode: "SSL_VERIFY_NONE";' gtmcrypt.cfg
echo

echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t4_srclogs = "SRC_${time_src}.log"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t4_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the Receiver Server to report the missing PHA extension"
$gtm_tst/com/wait_for_log.csh -log $t4_rcvrlog -message "Post-handshake authentication failure" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
echo

# As in Test 3, guard the backquotes so an absent log cannot turn the comparisons into tcsh syntax errors. The
# defaults chosen here make every assertion below report a failure.
if (-e $t4_rcvrlog) then
	set t4_phafail_cnt = `$grep -c "Post-handshake authentication failure" $t4_rcvrlog`
	set t4_error_cnt = `$grep -c "GTM-E-TLSHANDSHAKE" $t4_rcvrlog`
	set t4_warning_cnt = `$grep -c "GTM-W-TLSHANDSHAKE" $t4_rcvrlog`
	set t4_fallback_cnt = `$grep -c "Post-handshake fallback enabled" $t4_rcvrlog`
	set t4_secure_cnt = `$grep -c "Secure communication enabled using TLS/SSL protocol" $t4_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t4_phafail_cnt = 0
	set t4_error_cnt = 0
	set t4_warning_cnt = 1
	set t4_fallback_cnt = 1
	set t4_secure_cnt = 1
endif

echo "# Confirm the Receiver Server reported that the Source Server did not send the PHA extension"
if (0 < $t4_phafail_cnt) then
	echo "TEST-I-PASSED Receiver Server reported a post-handshake authentication failure"
else
	echo "TEST-E-FAILED Receiver Server did not report a post-handshake authentication failure"
endif

echo "# Confirm TLSHANDSHAKE came out at error severity, since neither fallback is enabled"
if ((0 < $t4_error_cnt) && (0 == $t4_warning_cnt)) then
	echo "TEST-I-PASSED Receiver Server issued %GTM-E-TLSHANDSHAKE and no warning"
else
	echo "TEST-E-FAILED Expected %GTM-E-TLSHANDSHAKE and no %GTM-W-TLSHANDSHAKE, found $t4_error_cnt error(s) and $t4_warning_cnt warning(s)"
endif

echo "# Confirm the Receiver Server did not fall back, since 'post-handshake-fallback' is not enabled"
if (0 == $t4_fallback_cnt) then
	echo "TEST-I-PASSED Receiver Server issued no post-handshake fallback message"
else
	echo "TEST-E-FAILED Receiver Server issued $t4_fallback_cnt post-handshake fallback message(s)"
endif

echo "# Confirm no connection succeeded, since SSL_VERIFY_POST_HANDSHAKE was never dropped"
if (0 == $t4_secure_cnt) then
	echo "TEST-I-PASSED No TLS connection succeeded"
else
	echo "TEST-E-FAILED $t4_secure_cnt TLS connection(s) succeeded"
endif
echo

# The Receiver Server log holds the expected %GTM-E-TLSHANDSHAKE errors, and the Source Server log holds whatever
# the Source Server reported when the Receiver Server dropped the connection.
if (-e $t4_rcvrlog) mv $t4_rcvrlog ${t4_rcvrlog}x
foreach t4_srclog ($t4_srclogs)
	if (-e $t4_srclog) mv $t4_srclog ${t4_srclog}x
end

echo "### Test 5: verify-mode with another SSL_VERIFY_* option but without SSL_VERIFY_PEER, in a TLSID section"
echo "## Expect TLSCONVSOCK when the Server reads the TLS configuration for its TLSID. The reference plugin"
echo "## reports 'needs SSL_VERIFY_PEER to enable other options' as the accompanying TEXT."
echo "## This stage enables plaintext fallback with the MUPIP -plaintextfallback qualifier, which turns the"
echo "## otherwise fatal TLSCONVSOCK into a warning and keeps the Receiver Server alive. That keeps the output"
echo "## deterministic, and covers the same plugin check as the fatal form does."
echo

echo "# Restore both configs to their initial state"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Receiver Server (INST2): SSL_VERIFY_FAIL_IF_NO_PEER_CERT with no SSL_VERIFY_PEER to enable it"
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_FAIL_IF_NO_PEER_CERT";' $SEC_SIDE/gtmcrypt.cfg
echo

echo "# Pass -plaintextfallback to both replication servers"
setenv gtm_test_plaintext_fallback
echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t5_srclogs = "SRC_${time_src}.log"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t5_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the Receiver Server to reject the TLSID configuration"
$gtm_tst/com/wait_for_log.csh -log $t5_rcvrlog -message "TLSCONVSOCK" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
unsetenv gtm_test_plaintext_fallback
echo

if (-e $t5_rcvrlog) then
	set t5_convsock_cnt = `$grep -c "GTM-W-TLSCONVSOCK" $t5_rcvrlog`
	set t5_reason_cnt = `$grep -c "needs SSL_VERIFY_PEER to enable other options" $t5_rcvrlog`
	set t5_fallback_cnt = `$grep -c "Plaintext fallback enabled" $t5_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t5_convsock_cnt = 0
	set t5_reason_cnt = 0
	set t5_fallback_cnt = 0
endif

echo "# Confirm the Receiver Server issued TLSCONVSOCK when it read the configuration for its TLSID"
if (0 < $t5_convsock_cnt) then
	echo "TEST-I-PASSED Receiver Server issued %GTM-W-TLSCONVSOCK"
else
	echo "TEST-E-FAILED Receiver Server did not issue %GTM-W-TLSCONVSOCK"
endif

echo "# Confirm the accompanying TEXT names the missing SSL_VERIFY_PEER as the reason"
if (0 < $t5_reason_cnt) then
	echo "TEST-I-PASSED Reason reported as needing SSL_VERIFY_PEER to enable other options"
else
	echo "TEST-E-FAILED Reason not reported as needing SSL_VERIFY_PEER to enable other options"
endif

echo "# Confirm the Receiver Server fell back to plaintext rather than terminating"
if (0 < $t5_fallback_cnt) then
	echo "TEST-I-PASSED Receiver Server fell back to plaintext"
else
	echo "TEST-E-FAILED Receiver Server did not fall back to plaintext"
endif
echo

if (-e $t5_rcvrlog) mv $t5_rcvrlog ${t5_rcvrlog}x
foreach t5_srclog ($t5_srclogs)
	if (-e $t5_srclog) mv $t5_srclog ${t5_srclog}x
end

echo "### Test 6: verify-mode with another SSL_VERIFY_* option but without SSL_VERIFY_PEER, outside any TLSID section"
echo "## The same misconfiguration in the global part of the TLS configuration file is read at server startup"
echo "## rather than when the Server reads its TLSID, so expect TLSINIT instead of TLSCONVSOCK."
echo "## Plaintext fallback is again supplied on the command line to keep the Source Server alive."
echo

echo "# Restore both configs to their initial state"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Source Server (INST1): put the bad verify-mode in the global section, outside any TLSID"
sed -i '/^tls: {/a\	verify-mode: "SSL_VERIFY_FAIL_IF_NO_PEER_CERT";' gtmcrypt.cfg
echo

echo "# Pass -plaintextfallback to both replication servers"
setenv gtm_test_plaintext_fallback
echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t6_srclog = "SRC_${time_src}.log"

echo "# Wait for the Source Server to reject the configuration at startup"
$gtm_tst/com/wait_for_log.csh -log $t6_srclog -message "TLSINIT" -count 1 -duration 120

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t6_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Stop both replication instances"
$MSR STOP INST1 INST2
unsetenv gtm_test_plaintext_fallback
echo

if (-e $t6_srclog) then
	set t6_init_cnt = `$grep -c "GTM-W-TLSINIT" $t6_srclog`
	set t6_reason_cnt = `$grep -c "needs SSL_VERIFY_PEER to enable other options" $t6_srclog`
	set t6_fallback_cnt = `$grep -c "TLS/SSL communication will not be attempted again" $t6_srclog`
else
	echo "TEST-E-FAILED Source Server log not found"
	set t6_init_cnt = 0
	set t6_reason_cnt = 0
	set t6_fallback_cnt = 0
endif

echo "# Confirm the Source Server issued TLSINIT at startup"
if (0 < $t6_init_cnt) then
	echo "TEST-I-PASSED Source Server issued %GTM-W-TLSINIT"
else
	echo "TEST-E-FAILED Source Server did not issue %GTM-W-TLSINIT"
endif

echo "# Confirm the accompanying TEXT names the missing SSL_VERIFY_PEER as the reason"
if (0 < $t6_reason_cnt) then
	echo "TEST-I-PASSED Reason reported as needing SSL_VERIFY_PEER to enable other options"
else
	echo "TEST-E-FAILED Reason not reported as needing SSL_VERIFY_PEER to enable other options"
endif

echo "# Confirm the Source Server gave up on TLS for the rest of its run rather than terminating"
if (0 < $t6_fallback_cnt) then
	echo "TEST-I-PASSED Source Server fell back to plaintext for the rest of its run"
else
	echo "TEST-E-FAILED Source Server did not fall back to plaintext"
endif
echo

if (-e $t6_srclog) mv $t6_srclog ${t6_srclog}x
if (-e $t6_rcvrlog) mv $t6_rcvrlog ${t6_rcvrlog}x

echo "### Test 7: 'plaintext-fallback' enabled in the configuration file, and TLS negotiation succeeds"
echo "## Expect the fallback action not to execute: the connection is negotiated with TLS as usual and no"
echo "## plaintext fallback message appears. 'plaintext-fallback' only sets a default action for failures."
echo

echo "# Restore both configs to their initial state"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Enable 'plaintext-fallback' on both sides, leaving the rest of the configuration healthy"
sed -i '/^.*INSTANCE1: {/a\		plaintext-fallback: 1;' gtmcrypt.cfg
sed -i '/^.*INSTANCE2: {/a\		plaintext-fallback: 1;' $SEC_SIDE/gtmcrypt.cfg
echo

echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t7_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the TLS connection to be established"
$gtm_tst/com/wait_for_log.csh -log $t7_rcvrlog -message "Secure communication enabled using TLS/SSL protocol" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
echo

if (-e $t7_rcvrlog) then
	set t7_secure_cnt = `$grep -c "Secure communication enabled using TLS/SSL protocol" $t7_rcvrlog`
	set t7_fallback_cnt = `$grep -c "Plaintext fallback enabled" $t7_rcvrlog`
	set t7_handshake_cnt = `$grep -c "TLSHANDSHAKE" $t7_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t7_secure_cnt = 0
	set t7_fallback_cnt = 1
	set t7_handshake_cnt = 1
endif

echo "# Confirm the connection was negotiated with TLS"
if (0 < $t7_secure_cnt) then
	echo "TEST-I-PASSED Receiver Server enabled secure communication"
else
	echo "TEST-E-FAILED Receiver Server did not enable secure communication"
endif

echo "# Confirm the fallback action did not execute, since nothing failed"
if ((0 == $t7_fallback_cnt) && (0 == $t7_handshake_cnt)) then
	echo "TEST-I-PASSED No plaintext fallback and no TLSHANDSHAKE"
else
	echo "TEST-E-FAILED Found $t7_fallback_cnt plaintext fallback message(s) and $t7_handshake_cnt TLSHANDSHAKE message(s)"
endif
echo

echo "### Test 8: 'plaintext-fallback' enabled in the configuration file, and TLS negotiation fails"
echo "## Expect the fallback action to execute: TLSHANDSHAKE comes out as a warning rather than an error and"
echo "## both Servers reconnect without TLS. The negotiation is made to fail by removing the Source Server's"
echo "## client certificate, which the Receiver Server requires because its TLSID specifies no verify-mode and"
echo "## therefore defaults to SSL_VERIFY_PEER with SSL_VERIFY_FAIL_IF_NO_PEER_CERT, per GTM-DE568389."
echo

echo "# Restore both configs to their initial state"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Enable 'plaintext-fallback' on both sides"
sed -i '/^.*INSTANCE1: {/a\		plaintext-fallback: 1;' gtmcrypt.cfg
sed -i '/^.*INSTANCE2: {/a\		plaintext-fallback: 1;' $SEC_SIDE/gtmcrypt.cfg

echo "# Remove the Source Server's client certificate so the TLS handshake cannot succeed"
sed -i '/cert.*INSTANCE1.*/d' gtmcrypt.cfg
echo

echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t8_srclogs = "SRC_${time_src}.log"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t8_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the Receiver Server to fall back to plaintext"
$gtm_tst/com/wait_for_log.csh -log $t8_rcvrlog -message "Plaintext fallback enabled" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
echo

if (-e $t8_rcvrlog) then
	set t8_warning_cnt = `$grep -c "GTM-W-TLSHANDSHAKE" $t8_rcvrlog`
	set t8_error_cnt = `$grep -c "GTM-E-TLSHANDSHAKE" $t8_rcvrlog`
	set t8_fallback_cnt = `$grep -c "Plaintext fallback enabled" $t8_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t8_warning_cnt = 0
	set t8_error_cnt = 1
	set t8_fallback_cnt = 0
endif

echo "# Confirm TLSHANDSHAKE came out as a warning rather than an error, because the fallback is enabled"
if ((0 < $t8_warning_cnt) && (0 == $t8_error_cnt)) then
	echo "TEST-I-PASSED Receiver Server issued %GTM-W-TLSHANDSHAKE and no error"
else
	echo "TEST-E-FAILED Expected %GTM-W-TLSHANDSHAKE and no %GTM-E-TLSHANDSHAKE, found $t8_warning_cnt warning(s) and $t8_error_cnt error(s)"
endif

echo "# Confirm the fallback action executed"
if (0 < $t8_fallback_cnt) then
	echo "TEST-I-PASSED Receiver Server fell back to plaintext"
else
	echo "TEST-E-FAILED Receiver Server did not fall back to plaintext"
endif
echo

if (-e $t8_rcvrlog) mv $t8_rcvrlog ${t8_rcvrlog}x
foreach t8_srclog ($t8_srclogs)
	if (-e $t8_srclog) mv $t8_srclog ${t8_srclog}x
end

echo "### Test 9: MUPIP -plaintextfallback with 'plaintext-fallback' absent from the configuration file"
echo "## The configuration file sets the default action, and the command line qualifier overrides it. With no"
echo "## 'plaintext-fallback' in the configuration the default is not to fall back, so -plaintextfallback on the"
echo "## command line is what allows the fallback here. The negotiation is made to fail exactly as in Test 8."
echo "##"
echo "## Note that only this direction of the override is reachable. The Servers compute plaintext fallback as"
echo "## the logical OR of the command line qualifier and the configuration file setting, so -noplaintextfallback"
echo "## cannot disallow a fallback that the configuration file has enabled. See the thread at"
echo "## https://gitlab.com/YottaDB/DB/YDBTest/-/issues/716 for details."
echo

echo "# Restore both configs to their initial state, leaving 'plaintext-fallback' out of both"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

echo "# Remove the Source Server's client certificate so the TLS handshake cannot succeed"
sed -i '/cert.*INSTANCE1.*/d' gtmcrypt.cfg
echo

echo "# Pass -plaintextfallback to both replication servers"
setenv gtm_test_plaintext_fallback
echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
set t9_srclogs = "SRC_${time_src}.log"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t9_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the Receiver Server to fall back to plaintext"
$gtm_tst/com/wait_for_log.csh -log $t9_rcvrlog -message "Plaintext fallback enabled" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
unsetenv gtm_test_plaintext_fallback
echo

if (-e $t9_rcvrlog) then
	set t9_warning_cnt = `$grep -c "GTM-W-TLSHANDSHAKE" $t9_rcvrlog`
	set t9_error_cnt = `$grep -c "GTM-E-TLSHANDSHAKE" $t9_rcvrlog`
	set t9_fallback_cnt = `$grep -c "Plaintext fallback enabled" $t9_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t9_warning_cnt = 0
	set t9_error_cnt = 1
	set t9_fallback_cnt = 0
endif

echo "# Confirm the command line qualifier allowed the fallback that the configuration file did not"
if ((0 < $t9_warning_cnt) && (0 == $t9_error_cnt) && (0 < $t9_fallback_cnt)) then
	echo "TEST-I-PASSED Receiver Server warned and fell back to plaintext"
else
	echo "TEST-E-FAILED Expected a warning and a fallback, found $t9_warning_cnt warning(s), $t9_error_cnt error(s) and $t9_fallback_cnt fallback message(s)"
endif
echo

if (-e $t9_rcvrlog) mv $t9_rcvrlog ${t9_rcvrlog}x
foreach t9_srclog ($t9_srclogs)
	if (-e $t9_srclog) mv $t9_srclog ${t9_srclog}x
end

echo "### Test 10: MUPIP -plaintextfallback, and TLS negotiation succeeds"
echo "## The counterpart to Test 9, and to Test 7 for the command line rather than the configuration file."
echo "## Expect the fallback action not to execute, because nothing failed."
echo

echo "# Restore both configs to their initial state, leaving 'plaintext-fallback' out of both"
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg
echo

echo "# Pass -plaintextfallback to both replication servers"
setenv gtm_test_plaintext_fallback
echo "# Start source replication instance"
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"

echo "# Start receiver replication instance"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"
set t10_rcvrlog = "$SEC_SIDE/RCVR_${time_rcvr}.log"
echo

echo "# Wait for the TLS connection to be established"
$gtm_tst/com/wait_for_log.csh -log $t10_rcvrlog -message "Secure communication enabled using TLS/SSL protocol" -count 1 -duration 120
echo "# Stop both replication instances"
$MSR STOP INST1 INST2
unsetenv gtm_test_plaintext_fallback
echo

if (-e $t10_rcvrlog) then
	set t10_secure_cnt = `$grep -c "Secure communication enabled using TLS/SSL protocol" $t10_rcvrlog`
	set t10_fallback_cnt = `$grep -c "Plaintext fallback enabled" $t10_rcvrlog`
	set t10_handshake_cnt = `$grep -c "TLSHANDSHAKE" $t10_rcvrlog`
else
	echo "TEST-E-FAILED Receiver Server log not found"
	set t10_secure_cnt = 0
	set t10_fallback_cnt = 1
	set t10_handshake_cnt = 1
endif

echo "# Confirm the connection was negotiated with TLS"
if (0 < $t10_secure_cnt) then
	echo "TEST-I-PASSED Receiver Server enabled secure communication"
else
	echo "TEST-E-FAILED Receiver Server did not enable secure communication"
endif

echo "# Confirm the fallback action did not execute, even though the command line allowed it"
if ((0 == $t10_fallback_cnt) && (0 == $t10_handshake_cnt)) then
	echo "TEST-I-PASSED No plaintext fallback and no TLSHANDSHAKE"
else
	echo "TEST-E-FAILED Found $t10_fallback_cnt plaintext fallback message(s) and $t10_handshake_cnt TLSHANDSHAKE message(s)"
endif
echo

# Restore both configurations before teardown, so anything dbcheck.csh starts sees a healthy TLS configuration
cp $SEC_SIDE/gtmcryptINIT.cfg $SEC_SIDE/gtmcrypt.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg

$gtm_tst/com/dbcheck.csh >& dbcheck.out
