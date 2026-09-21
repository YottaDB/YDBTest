#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
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
GTM-DE567906 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE567906)

The Receiver Server continues to operate after a TLSHANDSHAKE or REPLNOTLS error. The Source Server operation is unchanged, without plaintext fallback enabled, it terminates for all TLSHANDSHAKE or REPLNOTLS errors. Previously, the Receiver Server terminated when issuing such an error. (GTM-DE567906)

CAT_EOF
echo

setenv gtm_test_tls TRUE
source $gtm_tst/com/set_tls_env.csh
# The Receiver Server previously only terminated on TLSHANDSHAKE and REPLNOTLS errors when started without plaintext fallback.
# Now, it continues to operate when these errors are encountered and plaintext fallback is disabled. So start the Receiver Server
# without plaintext fallback in this test.
unsetenv gtm_test_plaintext_fallback

$MULTISITE_REPLIC_PREPARE 2

$MULTISITE_REPLIC_ENV

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
echo

echo "### Test 1: Receiver Server continues to operate after a REPLNOTLS error"
echo "# Start the Source Server without -TLSID, so it does not request TLS/SSL communication"
# Set gtm_test_tls to FALSE only when starting the source server, since this causes com/set_var_tlsparm.csh to omit -TLSID from the Source Server command
setenv gtm_test_tls FALSE
$MSR STARTSRC INST1 INST2 RP
# Set gtm_test_tls to TRUE now that the source server has started
setenv gtm_test_tls TRUE
echo "# Start the Receiver Server with -TLSID and without plaintext fallback"
$MSR STARTRCV INST1 INST2
get_msrtime
set rcvr_log = $SEC_SIDE/RCVR_${time_msr}.log
echo
echo "# Wait for a second REPLNOTLS error from the Receiver Server. The Receiver Server closes the connection after each"
echo "# REPLNOTLS error and the Source Server reconnects, so a second error means the Receiver Server survived the first one."
echo "# Previously, the Receiver Server terminated after the first REPLNOTLS error."
$gtm_tst/com/wait_for_log.csh -log $rcvr_log -message "REPLNOTLS" -count 2 -duration 120
echo "# Verify the Receiver Server is still alive"
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replic -receiver -checkhealth' >&! checkhealth_test1_before.out
set rcvr_pid_before = `$tst_awk '/PID.*Receiver server is alive/ {print $2}' checkhealth_test1_before.out`
if ("" == "$rcvr_pid_before") then
	echo "TEST-E-FAIL, Receiver Server is not alive after a REPLNOTLS error. See checkhealth_test1_before.out"
	$MSR STOP INST1 INST2 >&! stop_after_failure.out
	exit 1
else
	echo "# Receiver Server is alive"
endif
echo

echo "## Restart the Source Server with -TLSID and verify the same Receiver Server process replicates updates using TLS/SSL"
$MSR STOPSRC INST1 INST2
$MSR STARTSRC INST1 INST2 RP
echo "# Run an update on INST1 to confirm replication is working correctly over TLS/SSL"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10' >&! update_test1.out
$MSR SYNC INST1 INST2
$gtm_tst/com/wait_for_log.csh -log $rcvr_log -message "Secure communication enabled using TLS/SSL protocol" -duration 60
echo "# Confirm the receiver server is still running with the same PID"
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replic -receiver -checkhealth' >&! checkhealth_test1_after.out
set rcvr_pid_after = `$tst_awk '/PID.*Receiver server is alive/ {print $2}' checkhealth_test1_after.out`
if ("$rcvr_pid_before" == "$rcvr_pid_after") then
	echo "# Receiver Server PID is unchanged"
else
	echo "TEST-E-FAIL, Receiver Server PID changed from [$rcvr_pid_before] to [$rcvr_pid_after]"
endif
$MSR STOP INST1 INST2
$gtm_tst/com/check_error_exist.csh $rcvr_log REPLNOTLS | uniq	# Omit duplicate instances of REPLNOTLS
echo

echo "### Test 2: Receiver Server continues to operate after a TLSHANDSHAKE error"
echo "# Remove the certificate and private key from the Source Server TLS configuration, so that the Source Server presents no"
echo "# certificate, and require a peer certificate in the Receiver Server TLS configuration, so that the missing certificate"
echo "# causes a TLSHANDSHAKE error in the Receiver Server."
# Each instance has its own gtmcrypt.cfg, so this only changes the configuration of the Source Server (INST1). Only the
# INSTANCE1 section is edited, as INSTANCE10 uses the same certificate and key files.
# The handshake must fail in the Receiver Server's certificate verification. Removing CAfile from the Source Server
# configuration instead does not work: with no verify-mode configured, the Source Server (the TLS client) does not verify
# the Receiver Server certificate during the handshake, and only issues a TLSCONNINFO warning afterwards.
# It has to be the Source Server configuration that is broken and later repaired, since the Receiver Server reads its
# configuration only at startup and the same Receiver Server process has to accept a good connection later in this test.
cp gtmcrypt.cfg gtmcrypt_good.cfg
sed '/^[[:space:]]*INSTANCE1: {/,/};/{/cert:\|key:/d}' gtmcrypt_good.cfg >&! gtmcrypt.cfg
echo "# Start the Source Server with -TLSID and plaintext fallback, so it reconnects rather than terminating after the"
echo "# handshake error"
setenv gtm_test_plaintext_fallback
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
echo "# Require a peer certificate in the INSTANCE2 section of the Receiver Server TLS configuration"
# V7.1-003 defaults verify-mode to SSL_VERIFY_PEER:SSL_VERIFY_FAIL_IF_NO_PEER_CERT (GTM-DE568389), but setting it here as well
# means this test does not depend on that default, and so still reproduces the TLSHANDSHAKE error against a build without the
# GTM-DE567906 fix, where it terminates the Receiver Server.
# The Receiver Server reads its configuration only at startup, so this has to happen before the STARTRCV below. It stays in
# place for the rest of this test: the Source Server certificate is restored later and the handshake then succeeds.
sed -i '/^.*INSTANCE2: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_FAIL_IF_NO_PEER_CERT";' $SEC_SIDE/gtmcrypt.cfg
# Confirm the edit took. Were it to silently stop matching, this test would fall back on the GTM-DE568389 default: it would keep
# passing on V7.1-003 while no longer being able to fail on a build without the GTM-DE567906 fix. The only other verify-mode in
# com/tls/gtmtls.cfg is a plain "SSL_VERIFY_PEER", which does not match the pattern below.
set verify_mode_lines = `grep -c 'verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_FAIL_IF_NO_PEER_CERT"' $SEC_SIDE/gtmcrypt.cfg`
if ("1" != "$verify_mode_lines") then
	echo "TEST-E-FAIL, verify-mode was not added to the INSTANCE2 section of $SEC_SIDE/gtmcrypt.cfg"
	$MSR STOPSRC INST1 INST2 >&! stop_after_failure.out
	exit 1
endif
echo "# Start the Receiver Server with -TLSID and without plaintext fallback"
unsetenv gtm_test_plaintext_fallback
$MSR STARTRCV INST1 INST2
get_msrtime
set rcvr_log = $SEC_SIDE/RCVR_${time_msr}.log
echo
echo "# Wait for a TLSHANDSHAKE error from the Receiver Server"
$gtm_tst/com/wait_for_log.csh -log $rcvr_log -message "TLSHANDSHAKE" -duration 60
echo "# Wait for a second error from the Receiver Server. After the failed handshake, the Source Server reconnects, by either"
echo "# retrying TLS/SSL (another TLSHANDSHAKE error) or falling back to plaintext (a REPLNOTLS error), depending on timing."
echo "# Either error means that the Receiver Server survived the first TLSHANDSHAKE error."
echo "# Previously, the Receiver Server terminated after the first TLSHANDSHAKE error."
$gtm_tst/com/wait_for_log.csh -log $rcvr_log -message "TLSHANDSHAKE|REPLNOTLS" -useE -count 2 -duration 60
echo "# Verify the Receiver Server is still alive"
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replic -receiver -checkhealth' >&! checkhealth_test2_before.out
set rcvr_pid_before = `$tst_awk '/PID.*Receiver server is alive/ {print $2}' checkhealth_test2_before.out`
if ("" == "$rcvr_pid_before") then
	echo "TEST-E-FAIL, Receiver Server is not alive after a TLSHANDSHAKE error. See checkhealth_test2_before.out"
	$MSR STOP INST1 INST2 >&! stop_after_failure.out
	exit 1
else
	echo "# Receiver Server is alive"
endif
echo
echo "# Restore the Source Server's original TLS configuration, then restart the Source Server without plaintext fallback, and verify that the"
echo "# same Receiver Server process replicates updates using TLS/SSL"
$MSR STOPSRC INST1 INST2
# The Source Server log above contains one warning caused by the certificate removed above, and where that failure surfaces
# depends on the TLS protocol version negotiated. With TLS 1.3, the Receiver Server completes the handshake before it verifies the
# peer certificate, so the Source Server sees the "certificate required" alert on its next receive and reports YDB-W-TLSIOERROR,
# the Source Server side of the failure the Receiver Server reports as YDB-E-TLSHANDSHAKE. With TLS 1.2, the alert arrives during
# the handshake itself and the Source Server reports YDB-W-TLSHANDSHAKE instead. Mask those two messages, and only those, so the
# test framework does not report them as errors. The REPLNOTLS that follows the Source Server's plaintext fallback does not appear
# here: the fallback clears the Source Server's TLS request, so only the Receiver Server issues it.
$gtm_tst/com/knownerror.csh SRC_${time_src}.log "YDB-W-TLSIOERROR|YDB-W-TLSHANDSHAKE"
echo "# Restore the TLS configuration"
cp gtmcrypt_good.cfg gtmcrypt.cfg
echo "# Start the source server"
$MSR STARTSRC INST1 INST2 RP
echo "# Run an update on INST1 to confirm replication is working"
$MSR RUN INST1 '$gtm_tst/com/simpleinstanceupdate.csh 10' >&! update_test2.out
$MSR SYNC INST1 INST2
echo "# Confirm that TLS is working"
$gtm_tst/com/wait_for_log.csh -log $rcvr_log -message "Secure communication enabled using TLS/SSL protocol" -duration 60
echo "# Confirm that the receiver server is still running with the same PID"
$MSR RUN INST2 'set msr_dont_chk_stat ; $MUPIP replic -receiver -checkhealth' >&! checkhealth_test2_after.out
set rcvr_pid_after = `$tst_awk '/PID.*Receiver server is alive/ {print $2}' checkhealth_test2_after.out`
if ("$rcvr_pid_before" == "$rcvr_pid_after") then
	echo "# Receiver Server PID is unchanged"
else
	echo "TEST-E-FAIL, Receiver Server PID changed from [$rcvr_pid_before] to [$rcvr_pid_after]"
endif
$MSR STOP INST1 INST2
# Whether the Receiver Server also issued REPLNOTLS errors depends on timing (see above), so mask them without checking.
# This must run before check_error_exist.csh, which then preserves the unmasked log as a timestamped .logx file.
$gtm_tst/com/knownerror.csh $rcvr_log "YDB-E-REPLNOTLS"
$gtm_tst/com/check_error_exist.csh $rcvr_log TLSHANDSHAKE | uniq	# Omit duplicate instances of TLSHANDSHAKE
echo

$gtm_tst/com/dbcheck.csh -extract INST1 INST2 >& dbcheck.out
if ($status) then
	echo "TEST-E-DBCHECK, dbcheck.csh failed. See dbcheck.out"
endif
