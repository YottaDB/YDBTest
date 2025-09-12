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
GTM-F248691 - Test the following part of the release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F248691)

GT.M applies these configuration options only to GT.M replication Servers and ignores them for SOCKET devices
because these options are part of the replication protocol. Applications using SOCKET devices can imitate either
fallback option by checking \$DEVICE for the TLS connection failure reason and reacting appropriately.

The replication half of this release note is tested by v71003/tlsconfig_posthandshake-gtmf248691.

CAT_EOF
echo

# Each stage below runs the same SOCKET device scenario twice, once with the fallback option commented out of
# the TLS configuration file and once with it in effect, and compares the two outcomes. If the option were
# applied to SOCKET devices the second run would differ, so identical outcomes are what show it was ignored.
# Comparing two runs rather than matching expected message text also keeps this subtest independent of how a
# given OpenSSL version words a handshake failure.
#
# Two details of how the configuration file is edited matter:
#
# - The option goes in commented out rather than being added for the second run only, so that both runs read a
#   file with the same number of lines. A plugin message that cites a configuration file line number, as the
#   one for a malformed file does, would otherwise differ between the two runs for that reason alone.
#
# - The 'server' TLSID already specifies a verify-mode in the configuration file the harness generates, and the
#   plugin rejects the whole file on a duplicate setting name, so any existing verify-mode is deleted from the
#   TLSID being changed before a new one is added.

setenv ydb_msgprefix "GTM"

setenv gtm_test_tls TRUE
source $gtm_tst/com/set_tls_env.csh

set portno = `source $gtm_tst/com/portno_acquire.csh`

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
echo

cp $gtmcrypt_config gtmcryptINIT.cfg

echo "### Test 1: 'post-handshake-fallback' is ignored for SOCKET devices"
echo "## The server TLSID requires Post Handshake Authentication while the client TLSID uses SSL_VERIFY_NONE,"
echo "## so the client never sends the PHA extension. That is the configuration which makes a Receiver Server"
echo "## with 'post-handshake-fallback' temporarily drop SSL_VERIFY_POST_HANDSHAKE, as Test 3 of"
echo "## v71003/tlsconfig_posthandshake-gtmf248691 shows. Expect a SOCKET device to behave the same way whether"
echo "## or not the option is in effect."
echo

echo "# Server requires PHA, client does not advertise it"
cp gtmcryptINIT.cfg $gtmcrypt_config
sed -i '/^[[:space:]]*server: {/,/^[[:space:]]*};/{/verify-mode/d;}' $gtmcrypt_config
sed -i '/^[[:space:]]*client: {/,/^[[:space:]]*};/{/verify-mode/d;}' $gtmcrypt_config
sed -i '/^.*server: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_POST_HANDSHAKE";' $gtmcrypt_config
sed -i '/^.*client: {/a\		verify-mode: "SSL_VERIFY_NONE";' $gtmcrypt_config
sed -i '/^.*server: {/a\		#post-handshake-fallback: 1;' $gtmcrypt_config
cp $gtmcrypt_config gtmcryptT1a.cfg
echo "# Run with 'post-handshake-fallback' commented out"
source $gtm_tst/$tst/u_inref/tlsfallback_socket_run-gtmf248691.csh t1a

echo "# Uncomment 'post-handshake-fallback' and run again"
sed -i 's|#post-handshake-fallback: 1;|post-handshake-fallback: 1;|' $gtmcrypt_config
cp $gtmcrypt_config gtmcryptT1b.cfg
source $gtm_tst/$tst/u_inref/tlsfallback_socket_run-gtmf248691.csh t1b
echo

echo "# Confirm the plugin read both configurations, so that the comparison below is not between two"
echo "# identical failures to read the file, which would pass without testing anything"
if (0 == `cat outcome_t1a.out outcome_t1b.out | $grep -cE 'Failed to read config file|TLSPARAM|unknown'`) then
	echo "TEST-I-PASSED Both configurations were read successfully"
else
	echo "TEST-E-FAILED A configuration was rejected by the plugin"
	cat outcome_t1a.out outcome_t1b.out
endif

# Unlike Test 2 below, this stage does not assert that its scenario failed, because a SOCKET device that
# simply never attempts PHA would succeed on both runs and the option would still have been ignored. The
# cost is that the comparison stops discriminating if the connection ever negotiates a TLS version below
# 1.3, where there is no PHA to fall back from: both runs would then succeed identically and this stage
# would pass without exercising the fallback path at all. Nothing sets a version or ssl-options here, so
# the connection takes the OpenSSL default, which has been TLSv1.3. The error recorded in
# outcome_t1a.out says which it was: "extension not received" is the PHA request failing, and so is the
# evidence that the scenario was the intended one.
echo "# Compare the two outcomes"
diff outcome_t1a.out outcome_t1b.out >&! t1diff.out
if (0 == $status) then
	echo "TEST-I-PASSED SOCKET device behaved identically, so 'post-handshake-fallback' was ignored"
else
	echo "TEST-E-FAILED SOCKET device behaved differently with 'post-handshake-fallback'"
	cat t1diff.out
endif
echo

echo "### Test 2: 'plaintext-fallback' is ignored for SOCKET devices"
echo "## The server TLSID requires a peer certificate that the client cannot present, so the TLS handshake"
echo "## cannot succeed. That is the configuration which makes a replication Server with 'plaintext-fallback'"
echo "## reconnect without TLS, as Test 8 of v71003/tlsconfig_posthandshake-gtmf248691 shows. A SOCKET device"
echo "## has no such fallback, so expect the same outcome whether or not the option is in effect. An"
echo '## application wanting that behavior has to check $DEVICE and reconnect itself.'
echo

echo "# Server requires a peer certificate, and the client has no certificate to present"
cp gtmcryptINIT.cfg $gtmcrypt_config
sed -i '/^[[:space:]]*server: {/,/^[[:space:]]*};/{/verify-mode/d;}' $gtmcrypt_config
sed -i '/^.*server: {/a\		verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_FAIL_IF_NO_PEER_CERT";' $gtmcrypt_config
# The certificate files are named after the instance rather than after the TLSID, so the client's certificate
# has to be removed by its position within the 'client' block
sed -i '/^[[:space:]]*client: {/,/^[[:space:]]*};/{/^[[:space:]]*cert:/d;}' $gtmcrypt_config
sed -i '/^.*server: {/a\		#plaintext-fallback: 1;' $gtmcrypt_config
sed -i '/^.*client: {/a\		#plaintext-fallback: 1;' $gtmcrypt_config
cp $gtmcrypt_config gtmcryptT2a.cfg
echo "# Run with 'plaintext-fallback' commented out"
source $gtm_tst/$tst/u_inref/tlsfallback_socket_run-gtmf248691.csh t2a

echo "# Uncomment 'plaintext-fallback' in both TLSIDs and run again"
sed -i 's|#plaintext-fallback: 1;|plaintext-fallback: 1;|' $gtmcrypt_config
cp $gtmcrypt_config gtmcryptT2b.cfg
source $gtm_tst/$tst/u_inref/tlsfallback_socket_run-gtmf248691.csh t2b
echo

echo "# Confirm the plugin read both configurations"
if (0 == `cat outcome_t2a.out outcome_t2b.out | $grep -cE 'Failed to read config file|TLSPARAM|unknown'`) then
	echo "TEST-I-PASSED Both configurations were read successfully"
else
	echo "TEST-E-FAILED A configuration was rejected by the plugin"
	cat outcome_t2a.out outcome_t2b.out
endif

echo "# Confirm the handshake really did fail, so that the comparison below means something"
if (0 != `$grep -cE 'test=0|: error ' outcome_t2a.out`) then
	echo "TEST-I-PASSED TLS handshake failed as intended"
else
	echo "TEST-E-FAILED TLS handshake was expected to fail"
	cat outcome_t2a.out
endif

echo "# Compare the two outcomes"
diff outcome_t2a.out outcome_t2b.out >&! t2diff.out
if (0 == $status) then
	echo "TEST-I-PASSED SOCKET device behaved identically, so 'plaintext-fallback' was ignored"
else
	echo "TEST-E-FAILED SOCKET device behaved differently with 'plaintext-fallback'"
	cat t2diff.out
endif
echo

echo "# Restore the initial TLS configuration"
cp gtmcryptINIT.cfg $gtmcrypt_config

# The collected outcomes hold the expected TLS failure text, so rename them out of the error scanner's way
foreach tfs_tag (t1a t1b t2a t2b)
	foreach tfs_file (server_${tfs_tag}.out client_${tfs_tag}.out client_${tfs_tag}.err outcome_${tfs_tag}.out)
		if (-e $tfs_file) mv $tfs_file ${tfs_file}x
	end
end
foreach tfs_file (t1diff.out t2diff.out)
	if (-e $tfs_file) mv $tfs_file ${tfs_file}x
end

$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh >& dbcheck.out
