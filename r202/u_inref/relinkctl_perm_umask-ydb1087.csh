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

echo "###########################################################################################################"
echo "# Test that relinkctl file is writable by any userid that can read the routine object directory"
echo "###########################################################################################################"

# This test creates relinkctl files multiple times inside the "mumps -run ydb1097" invocation
# when it invokes "mumps -run run^ydb1097". Therefore disable creating relinkctl files as part
# of the "mumps -run ydb1097" invocation as it will affect the test output and cause false failures.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

# Create database to store random permission bits in the 8 test cases generated inside "ydb1097.m"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

# Compile "ydb1097.m" BEFORE umask is tampered with to ensure object file is readily available
# for the "mumps -run ydb1097" invocation below.
$gtm_dist/mumps $gtm_tst/$tst/inref/ydb1097.m

echo "# Randomly change the current umask value and make sure that does not affect the permission of the"
echo "# relinkctl files created inside the [mumps -run ydb1097] invocation."
echo "# This also tests https://gitlab.com/YottaDB/DB/YDB/-/issues/1087#note_1990208203"
set orig_umask = `umask`
set rand_umask = `$gtm_dist/mumps -run %XCMD 'write 0 for i=1:1:3 write $random(8)'`
echo $rand_umask > rand_umask.txt	# record random setting for debugging purposes in case of test failure
umask $rand_umask

echo "# Run [mumps -run ydb1097]"
$gtm_dist/mumps -run ydb1097

# Restore umask to original value now that "mumps -run ydb1097" invocation is done
umask $orig_umask

$gtm_tst/com/dbcheck.csh >& dbcheck.out
