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
GTM-F228991 - Test the following part of the release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-F228991)

Further, in certain situations where there is no consumer of the updates in the replication journal pool, such as when there are only passive or -JNLFILEONLY source servers, mumps processes do not write each commit into the replication journal pool (they continue to update instance-wide metadata like the sequence number). Previously, processes wrote every commit into the replication journal pool even if there was no consumer for that data. (GTM-F228991)

This subtest covers the "-JNLFILEONLY source server" case. The "passive source server" case is
covered by the "noconsumer_passivesrc-gtmf228991" subtest.

CAT_EOF
echo ""

# A -JNLFILEONLY source server reads the updates it ships from the journal files instead of from the
# journal pool, so it is not a consumer of journal pool data even though it is an ACTIVE source server
# with a receiver server connected to it.
setenv gtm_test_jnlfileonly 1
echo "setenv gtm_test_jnlfileonly 1" >> settings.csh

$MULTISITE_REPLIC_PREPARE 2
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo "# Start an ACTIVE source server with -JNLFILEONLY, and the receiver server"
$MSR START INST1 INST2

echo "# Do a few updates and dump the journal pool. Expect write_addr to be 0 and jnl_seqno to have advanced"
$gtm_exe/mumps -run gtmf228991

echo "# Wait for INST2 to catch up. The updates reach it from the journal files, not the journal pool"
$MSR SYNC INST1 INST2

echo "# Shut down the source and receiver servers"
$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
