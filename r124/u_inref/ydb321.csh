#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# --------------------------------------------------------------------"
echo "# Test that journal records fed to external filters include timestamps"
echo "# --------------------------------------------------------------------"
#
$MULTISITE_REPLIC_PREPARE 2
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
echo "# Define external filter for both source and receiver server as <mumps -run extfilter^ydb321>"
setenv gtm_tst_ext_filter_src "$gtm_exe/mumps -run extfilter^ydb321"
setenv gtm_tst_ext_filter_rcvr "$gtm_tst_ext_filter_src"
$MSR START INST1 INST2
echo "# Do one update on INST1"
$MSR RUN INST1 '$ydb_dist/mumps -run oneupdate^ydb321'
echo "# Wait for update to get played on receiver side before looking at external filter log files for timestamp"
$MSR SYNC INST1 INST2
echo "# Note down timestamp of update (from a MUPIP JOURNAL -EXTRACT) in time_jnlext.txt"
$MUPIP journal -extract -forward mumps.mjl >& jnlext.out
if ($status) then
	echo "# MUPIP journal -extract -forward mumps.mjl failed. Output of jnlext.out follows"
	cat jnlext.out
	exit -1
endif
$grep '\^x=' mumps.mjf | $tst_awk -F\\ '{print $2}' > time_jnlext.txt
echo "# Note down timestamp received by source server external filter in time_src_extfilter.txt"
# External filter logs journal records it receives (in journal extract format) into file log.extout
cp log.extout log.extout.src
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh _REMOTEINFO___RCV_DIR__/log.extout __SRC_DIR__/log.extout.rcvr'
# log.extout would contain 2 lines of "^x=", one for Received and one for Sent. Filter just the Received line (the first line)
$grep '\^x=' log.extout.src | head -1 | $tst_awk -F\\ '{print $2}' > time_src_extfilter.txt
echo "# Note down timestamp received by receiver server external filter in time_receiver_extfilter.txt"
$grep '\^x=' log.extout.rcvr | head -1 | $tst_awk -F\\ '{print $2}' > time_rcvr_extfilter.txt
echo -n "# Check that time_jnlext.txt and time_src_extfilter.txt are identical : "
diff time_jnlext.txt time_src_extfilter.txt >& diff1.log
if (! $status) then
	echo "PASS"
else
	echo "FAIL"
endif
echo -n "# Check that time_jnlext.txt and time_rcvr_extfilter.txt are identical : "
diff time_jnlext.txt time_rcvr_extfilter.txt >& diff2.log
if (! $status) then
	echo "PASS"
else
	echo "FAIL"
endif
echo "# Shutdown database"
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif

