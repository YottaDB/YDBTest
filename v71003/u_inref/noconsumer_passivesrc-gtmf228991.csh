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

This subtest covers the "passive source server" case. The "-JNLFILEONLY source server" case is
covered by the "noconsumer_jnlfileonly-gtmf228991" subtest.

CAT_EOF
echo ""

echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out

echo "# Turn on replication in the database file"
$MUPIP set -region "*" -replic=on -inst >&! mupipset.out

setenv gtm_repl_instance "mumps.repl"

echo "# Start a PASSIVE source server that allows local updates"
# Note : "com/passive_start_upd_enable.csh" starts the passive source server with -ROOTPRIMARY which
# is a synonym of the -UPDOK qualifier named in the release note.
source $gtm_tst/com/passive_start_upd_enable.csh >&! passive_start.out

echo "# Do a few updates and dump the journal pool. Expect write_addr to be 0 and jnl_seqno to have advanced"
$gtm_exe/mumps -run gtmf228991

echo "# Shut down the passive source server"
$MUPIP replicate -source -shutdown -timeout=0 >&! source_shutdown.out

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
