#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2020-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Testing mupip responds to SIGINT by shutting down cleanly"
echo "# Running an expect test for mupip integ response to CTRL^C"
expect $gtm_tst/$tst/u_inref/ydb635.exp > expect.out
echo "# With the last line in expect.out (File:), we can verify that mupip closed successfully"
# if the last line is different then we know the process didn't quit successfully and remaining exit statements
# got printed out when the subshell terminated
echo "# Checking last line of expect.out"
tail -1 expect.out
echo ""
echo "# End of mupip integ test"
