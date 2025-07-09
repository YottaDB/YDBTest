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
GTM-DE540134 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-003_Release_Notes.html#GTM-DE540134)

\$STORAGE reports the difference between the current \$ZREALSTOR as a subtrahend and, in order of precedence, \$ZMALLOCLIM if it has a non-zero value, the process R_LIMIT if it is not unlimited or less than the current the end of the process's data segment address, and otherwise the maximum of a 32-bit address space. Previously, \$STORAGE reported a large value that had little objective usefulness. (GTM-DE540134)

CAT_EOF
echo

echo "Note that this test does not test the case when R_LIMIT is not unlimited and"
echo "is less than the current end address of the process's data segment. This is because"
echo "it is difficult to identify the end address of process's data segment."
echo "For more information, see the discussion at:"
echo "https://gitlab.com/YottaDB/DB/YDBTest/-/issues/699#note_2629398665"
echo

$gtm_dist/mumps -r storage^gtmde540134
