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

echo '# -------------------------------------------------------------------------------------------------------------'
echo '# Test that WRITE /WAIT on socket device with multiple listening sockets return even with a timeout'
echo '# For more details on test case see: https://gitlab.com/YottaDB/DB/YDB/-/issues/1195'
echo '# -------------------------------------------------------------------------------------------------------------'

echo "# Get temporary port number"
source $gtm_tst/com/portno_acquire.csh >>& portno1.out
source $gtm_tst/com/portno_acquire.csh >>& portno2.out
echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

set port1 = `cat portno1.out`
set port2 = `cat portno2.out`
echo '## Run [ydb1195.m] test routine'
$gtm_dist/mumps -r ydb1195 $port1 $port2

$gtm_tst/com/portno_release.csh $port1
$gtm_tst/com/portno_release.csh $port2

$gtm_tst/com/dbcheck.csh >& dbcheck.out
