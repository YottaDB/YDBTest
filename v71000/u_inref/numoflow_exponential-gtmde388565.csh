#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2025 YottaDB LLC and/or its subsidiaries.	#
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
GTM-DE388565 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE388565)

GT.M handles string literal operands to a Boolean string relational operator where the literal contains an exponential format appropriately. Previously such a combination inappropriately produced a NUMOFLOW error if the numeric evaluation would have produced an error. (GTM-DE388565)
CAT_EOF
echo ''

setenv ydb_msgprefix "GTM"
echo "# Run a series of string relational operator comparisons,"
echo "# and expect no errors. Previously, NUMOFLOW errors would be"
echo "# issued. The following string relational operators are tested:"
echo "# =, [, ], ]], '=, '[, '], ']], ?, '?"
$gtm_dist/mumps -run ^gtmde388565 >& mumps.out
cat mumps.out
echo "# Run the Boolean literal optimization test case using mumps -machine -lis"
cp $gtm_tst/$tst/inref/gtmde388565bool.m .
$gtm_dist/mumps -machine -lis=boolLitOptimize.lis gtmde388565bool.m
echo '# Check mumps -machine -lis output to confirm that literal'
echo '# instructions are optimized, such that there are now 3-4 instructions'
echo '# (depending on whether dynamic literals are enabled). Previously, there'
echo '# were 12. Per the discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/645#note_2285637632:'
echo "# Notice no 'OC_BOOL*' opcodes above. Whereas, with the YDB master before GT.M V7.1-000 was merged, below is the output one sees which"
echo "# includes 'OC_BOOLINIT', 'OC_BOOLFINI' etc. all of which indicate triples corresponding to the boolean expression"
echo "# which implies the literal optimization did not happen at compile time."
grep -E ";OC_|PUSHL" boolLitOptimize.lis | sed 's/\s*[0-9]\s*\(.*\)/\1/g'
