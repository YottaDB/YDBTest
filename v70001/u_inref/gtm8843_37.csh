#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

source $gtm_tst/com/portno_acquire.csh >& portno.out
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.log
$gtm_dist/mumps -run procCleanupPrepare^gtm8843 $portno >& kill1.out

($gtm_dist/mumps -run srv37^gtm8843 $portno >& server.out &)
$gtm_dist/mumps -run cli37^gtm8843 $portno >& client.out

echo "# Build a TCP connection, the server hangs on a READ instruction."
echo "# The client sends an interrupt to the server, which, performs a"
echo "# I/O operation in interrupt handler routine. This leads to the"
echo "# desired error."
echo ---- server ----
cat -n server.out
echo ---- client ----
# Filter out line contains PID, printed by `mupip intrpt`
grep -v "INTRPT issued" client.out | cat -n

$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill2.out
$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh

sed -i '/\(ZINTRECURSEIO\)/d' server.out
