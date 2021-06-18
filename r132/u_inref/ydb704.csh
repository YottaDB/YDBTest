#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

# Autorelink is disabled for this test for now because it seems to be causing SIG-11s for the
# write 2*2 command due to some kind of issue that may be a valgrind issue and not a ydb issue.
# This appears to be related to valgrind's -q option which is necessary to keep the reference
# file simple.
source $gtm_tst/com/gtm_test_disable_autorelink.csh

echo "# Test invoking YottaDB via valgrind does not produce a %YDB-E-YDBDISTUNVERIF"

$echoline
echo "# First test valgrind -q $ydb_dist/yottadb -version"
valgrind -q $ydb_dist/yottadb -version

$echoline
echo '# Create a database and test valgrind -q $ydb_dist/mupip integ -reg "*"'
$gtm_tst/com/dbcreate.csh mumps
valgrind -q $ydb_dist/mupip integ -reg "*"

$echoline
echo "# Finally, test invoking a YottaDB command to write the result of 2*2 with valgrind."
valgrind -q $ydb_dist/yottadb -run ^%XCMD 'write "2*2 = ",2*2,!'
