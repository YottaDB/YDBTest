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

echo "# Test to ensure that implicit quits work and will exit the label."
echo "# Previously, a bug meant that implicit quits would cause a FALLINTOFLST error if used."
echo "# more discussion here https://gitlab.com/YottaDB/DB/YDB/-/work_items/1218#note_3174127739"
echo "# First the test should compile with a warning that an implied quit was added."
echo "# This will also include a second such warning for TEST2."
echo "# Then the test should run, writing out 'in do', without causing a FALLINTOFLST error as"
echo "# the added quit should return from the test before a FALLINTOFLST can happen."
$gtm_dist/mumps -run TEST1^ydb1218
echo "# Now starting test2 as a comparison"
echo "# This test has a set in the dotted line"
echo "# as thus the implicit quit still worked."
echo "# If the implicit quit still works, we expect no output."
$gtm_dist/mumps -run TEST2^ydb1218
echo "# Next starting ydb1218Quit.m to test the quit at the end of a DO block"
echo "# will no longer prevent the added QUIT from being mentioned at compile time."
echo "# We expect a compiler warning about an implicit QUIT being added."
$gtm_dist/mumps -run ydb1218Quit
