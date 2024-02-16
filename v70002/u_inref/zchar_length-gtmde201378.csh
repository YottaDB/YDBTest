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
#
cat << 'CAT_EOF' | sed 's/^/# /;'
********************************************************************************************
GTM-DE201378 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637455)

Operations that replace non-graphic characters with $[Z]CHAR() representations give a MAXSTRLEN error when the result would
exceed 1MiB. Previously such operations ensured they had adequate space for the result, but could pass strings to other
operations that might have no provision for dealing with strings longer than 1MiB. (GTM-DE201378)

This is a test from https://gitlab.com/YottaDB/DB/YDBTest/-/issues/577#note_1775232772.
When run with GT.M V7.0-002, it returns a string whose length is 6 more than MAXSTRLEN (1MiB).
This demonstrates that the fix in GTM-DE201378 is incomplete.
When run with YottaDB though, we expect a MAXSTRLEN error from this test (YDB#25 fixed this in r1.10).
This test exists to ensure that once GT.M V7.0-002 gets merged into YottaDB, there is no regression
of this correct behavior.

'CAT_EOF'

echo ""
setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
echo "# Drive gtmde201378 test routine"
$gtm_dist/mumps -run gtmde201378
