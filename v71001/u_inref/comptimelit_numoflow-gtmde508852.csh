#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
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
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE508852)

GT.M appropriately reports a NUMOFLOW error for literal values when those literals are operated on at compile-time and the run-time variable equivalent would trigger the same error. This affects the unary operators ',+, and -. The effect of these operators on variables is unchanged. Previously, these operators sometimes did not correctly report a NUMOFLOW when called for. In the case of the negation operator, this could lead to reporting an incorrect result. (GTM-DE508852)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"

echo "# Test NUMOFLOW error is issued for numeric unary operations on literals at compile-time that would yield the same error if executed at run-time"
echo "# Test [-] operator"
echo '## Test [write -"1E47"]:'
$gtm_dist/mumps -run %XCMD 'write -"1E47"'
echo '## Test [if -"1E47" write 1]:'
$gtm_dist/mumps -run %XCMD 'if -"1E47" write 1'
echo
echo "# Test [+] operator"
echo "# Note that [+] is following by [-] to cause the M compiler to distinguish"
echo "# the OC_NEG and OC_FORCENUM cases in sr_port/unary_tail.c."
echo "# See the discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2246#note_2398590527 for more details."
echo '## Test [write +-"1E47"]:'
$gtm_dist/mumps -run %XCMD 'write +-"1E47"'
echo '## Test [if +"1E47" write 1]:'
$gtm_dist/mumps -run %XCMD 'if +"1E47" write 1'
echo
echo "# Test ['] operator"
echo "## Test [write '"'"1E47"]:'
$gtm_dist/mumps -run %XCMD "write '"'"1E47"'
echo "## Test [if '"'"1E47" write 1]:'
$gtm_dist/mumps -run %XCMD "if '"'"1E47" write 1'
