#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018-2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
echo "# Test that the pattern match operator with alternation does not SIG-11 with input string as small as 16K"
echo "# This is an issue that was tracked https://gitlab.com/YottaDB/DB/YDB/issues/26"
echo "# But we noticed this was fixed when GT.M V6.3-005 was released as part of GTM-8965"
echo "# The new/correct behavior is a PATALTER2LARGE error (expected in the below output)"

# We have seen that this test fails with a core dump due to C-stack overflow.  The stack size limit is usually set to
# 8Mb in tcsh.  The gcc build of YottaDB runs for about 16K stack frames deep (recursion in do_patalt()) before issuing
# a PATALTER2LARGE error.  Each gcc stack frame of do_patalt() seems to take up significantly less space compared to
# a clang stack frame for the same function in a Debug build of YottaDB.  With clang in a Debug build, the stack size
# limit is reached way before frame #16384 is reached (when the PATALTER2LARGE error is issued) and so this causes the
# process to core dump. With gcc in a Debug build of YottaDB, a stack size limit of 8Mb is good enough for this test, but
# with clang a stack size limit of 64Mb is needed (even 32Mb causes a core dump).  In a Release build of YottaDB though,
# both clang and gcc seem to work with the 8Mb stack space fine. Given all this, just set the stack size limit to 64Mb
# all the time for this test whethere or not it is a gcc or clang build AND whether or not it is a Debug or Release build.
limit stacksize 65536 kbytes

$ydb_dist/mumps -run ^%XCMD 'for i=1:1:20 s x=$j(1,2**i) w "$zlength(x)=",$zlength(x)," : x?.(1""1"",1"" "") = ",x?.(1"1",1" "),!'

