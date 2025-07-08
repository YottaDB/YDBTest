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
GTM-DE201175 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE201175)

The Source and Receiver Servers start appropriately when input is redirected from /dev/null. Previously, FIS recommended starting the Source Server with input redirected from /dev/null to workaround GTM-8576. GT.M V6.3-004 included a fix for GTM-8576 that resulted in the workaround causing the Source Server to fail, so the workaround was to not use the obsolete workaround. (GTM-DE201175)

CAT_EOF
echo

source $gtm_tst/com/portno_acquire.csh >& portno.out
setenv gtm_repl_instance "mumps.repl"
setenv ydb_msgprefix "GTM"

echo "# Create a 1 region DB with gbl_dir mumps.gld and region DEFAULT" # , AREG, and BREG"
$gtm_tst/com/dbcreate.csh mumps 1 -gld_has_db_fullpath >& dbcreate_log.txt

echo "# Configure replication"
$gtm_dist/mupip set -journal="on,enable,nobefore" -replic=on -reg "*" >&! replication.log
echo "# Create a replication instance"
$gtm_dist/mupip replicate -instance_create -name=mumps.repl $gtm_test_qdbrundown_parms

echo "# Start replication on source and receiver servers with input redirect from /dev/null"
(expect -d $gtm_tst/$tst/u_inref/gtmde201175-source.exp $gtm_dist > expect-source.outx) >& expect-source.dbg
echo "# Shutdown the source server in case it is still running (expected in passing case)"
$gtm_dist/mupip replic -source -shutdown -timeout=0 >> shutdown.log
echo "# Start the source server to ensure there is a JNLPOOL for the receiver"
$gtm_dist/mupip replicate -source -start -passive -instsecondary=INSTANCE1 -buffsize=1048576 -log=source.log
(expect -d $gtm_tst/$tst/u_inref/gtmde201175-receiver.exp $gtm_dist $portno > expect-receiver.outx) >& expect-receiver.dbg
echo "# Expect no %GTM-E-TCSETATTR or %SYSTEM-E-ENO25 errors from the source or receiver server logs (source.log and receive.log)."
echo "# Prior to V7.1-003 and after V6.3-004, these errors would be issued."
cat source.log
cat receive.log

echo "# Stopping source server and receiver server"
$gtm_dist/mupip replic -receiver -shutdown -timeout=0 >>& server.log
$gtm_dist/mupip replic -source -shutdown -timeout=0 >> shutdown.log
$gtm_tst/com/portno_release.csh

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
