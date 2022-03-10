#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# This tests that %YDB-W-DONOBLOCK is suppressed by -nowarning by trying to"
echo "# compile an M program that contains a %YDB-W-DONOBLOCK errorl. Prior to V6.3-012,"
echo "# this warning was not suppressed by -nowarning."

$echoline
cat >> gtm9269.m << xx
	for i=1:1:5  do
	write "Finished iteration ",i," of loop",!
xx

echo '# First, unset $ydb_compile and $gtmcompile in case the test system set them automatically'
unsetenv ydb_compile
unsetenv gtmcompile

echo "# Run the program without -nowarning to verify that the code results in a %YDB-W-DONOBLOCK"

$ydb_dist/mumps -run gtm9269
$echoline

echo "# Now delete the object file, enable -nowarning and run it again to make sure"
echo "# the %YDB-W-DONOBLOCK is suppressed"
rm gtm9269.o
setenv ydb_compile "-nowarning"
$ydb_dist/mumps -run gtm9269
