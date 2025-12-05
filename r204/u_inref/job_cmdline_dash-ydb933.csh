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

echo "# Test for adding a command line argument with a dash '-' to a job command."
echo "# There used to be a bug where if the first command line argument passed into a job command"
echo "# starting with a dash it would produce an error. This should not happen anymore."
echo
echo "# Starting test"
set job_pid=`$gtm_dist/mumps -run ydb933`
$gtm_tst/com/wait_for_proc_to_die.csh $job_pid
echo "# Geting output [cat ydb933.mjo]"
cat "ydb933.mjo"
echo "# Checking that no error produced by job command [cat ydb933.mje]."
cat "ydb933.mje"
echo
echo '# Next test that "$gtm_dist/mumps -dir" has different behavior from a JOBed command.'
echo '# "$gtm_dist/mumps -dir -port" should still be an error'
echo "# As we decided this MR should not change it's behavior."
echo '# For more details see https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1792#note_2951733798'
echo "# As this should still give an error, we expect a CLIERR error below."
$gtm_dist/mumps -dir -port
