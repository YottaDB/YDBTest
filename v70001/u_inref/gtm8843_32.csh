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

($gtm_dist/mumps -run srv32^gtm8843 $portno >& server.out &)
$gtm_dist/mumps -run cli32^gtm8843 $portno >& client.out

echo "# This test starts a server-client pair, they connect, then the client"
echo "# triggers the error: missing argument for switching to blocking mode"
echo ---- server ----
cat -n server.out
echo ---- client ----
cat -n client.out

$gtm_dist/mumps -run procCleanupPerform^gtm8843 $portno >& kill2.out
$gtm_tst/com/dbcheck.csh >& dbcheck.log
$gtm_tst/com/portno_release.csh

sed -i '/\(SOCKBLOCKERR\)/d' client.out
