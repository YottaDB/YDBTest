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
cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F229760 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE559768)

GT.M frees memory associated with processing a pattern alternation, such as the '2U' in '.3(1N,2U)', when the processing encounters an error. Previously, GT.M failed to free this memory along certain error paths, resulting in a memory leak. (GTM-DE559768)

CAT_EOF
echo

echo "# The below test is based on the test case described at: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/702#note_2649354002"
echo

echo "# Run the gtmde559768 routine to perform pattern alternation operations in succession over a variety of iterations"
echo "# and check the memory allocation before and after each series of successive operations, e.g. check the memory before"
echo "# and after executing the pattern alternation 1 time, before and after executing it 2 times, etc. Expect an increase"
echo "# in memory allocation for the execution of the pattern alternation in the first iteration only."
echo "# All successive series of iterations should show an allocation increase of 0 confirming that there is no accumulating memory leak."
$gtm_dist/mumps -r gtmde559768
