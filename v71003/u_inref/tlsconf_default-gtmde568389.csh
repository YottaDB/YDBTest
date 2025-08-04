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
GTM-DE568389 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE568389)

The Receiver Server defaults SSL_VERIFY_PEER and SSL_VERIFY_FAIL_IF_NO_PEER_CERT if the ID in the TLS configuration file does not specify a verify-mode. Previously, the Receiver server defaulted to SSL_VERIFY_PEER. Customers desiring prior behavior should set verify-mode in the configuration file to just SSL_VERIFY_PEER. (GTM-DE568389)

CAT_EOF
echo

setenv gtm_test_tls TRUE
source $gtm_tst/com/set_tls_env.csh

$MULTISITE_REPLIC_PREPARE 2

$MULTISITE_REPLIC_ENV

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps 1  >& dbcreate.out
echo

echo "# Revise TLS configuration to omit client server certificate and verify-mode specification"
echo "# This will cause verify-mode to be implicitly set to 'SSL_VERIFY_PEER|SSL_VERIFY_FAIL_IF_NO_PEER_CERT'."
echo "# Previously, this would be set to only SSL_VERIFY_PEER by default."
cp gtmcrypt.cfg gtmcrypt-bak.cfg
sed -i '/cert.*INSTANCE1.*/d' gtmcrypt.cfg
sed -i '/verify-mode: "SSL_VERIFY_PEER"/d' gtmcrypt.cfg
if (0 == $ydb_test_tls13_plus) then
	# Force TLS v1.2
	sed -i '/session-timeout: 0/a	ssl-options: "SSL_OP_NO_TLSv1_3";' gtmcrypt.cfg
endif
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
echo "# Wait for TLSHANDSHAKE error from RCVR server, due to missing client server certificate."
echo "# A client server certificate is required when verify-mode includes SSL_VERIFY_PERR|SSL_VERIFY_FAIL_IF_NO_PEER_CERT."
echo "# Previously, no TLSHANDSHAKE error would be issued and the RCVR server would continue to operate,"
echo "# since verify-mode would be set to SSL_VERIFY_PEER only, which makes a client server certificate optional and not required,"
echo "# thus allowing continued RCVR server operation."
$MSR RUN INST1 '$gtm_tst/com/wait_for_log.csh -log '$SEC_SIDE/RCVR_$time_rcvr.log' -message TLSHANDSHAKE -duration 30'

$gtm_tst/com/check_error_exist.csh $SEC_SIDE/RCVR_$time_rcvr.log TLSHANDSHAKE | uniq	# Omit duplicate instances of TLSHANDSHAKE
echo

echo "# Expect TLSIOERROR (TLS versions >= 1.3) or TLSHANDSHAKE (TLS versions <= 1.2) error in source server log file"
echo "# as a result of the failed attempt to establish a TLS/SSL connection above due to a missing client certificate."
if (1 == $ydb_test_tls13_plus) then
	set message = TLSIOERROR
else
	set message = TLSHANDSHAKE
endif
$gtm_tst/com/wait_for_log.csh -log SRC_$time_src.log -message $message
$gtm_tst/com/check_error_exist.csh SRC_$time_src.log $message
echo

# Ensure source server has finished terminating before attempting error log check and restart
$MSR STOP INST1 INST2
$gtm_tst/com/wait_for_proc_to_die.csh `grep PID START_*.out | sed -E 's/.*PID ([0-9]+) Source server.*/\1/g' | uniq` 30

echo "# Restart source replication instance with restored gtmcrypt.cfg"
cp gtmcrypt.cfg gtmcrypt-test.cfg
cp gtmcrypt-bak.cfg gtmcrypt.cfg
$MSR STARTSRC INST1 INST2
echo "# Stop both replication instances"
# $MSR STOP INST2
echo

$gtm_tst/com/dbcheck.csh >& dbcheck.out
