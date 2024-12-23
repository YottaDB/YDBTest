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
GTM-DE340906 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE340906)

GT.M appropriately handles a command with multiple (more than 255) LOCKs with the same name. Previously, a GT.M command that created more than 255 LOCKs with the same name caused a segmentation violation (SIG-11). (GTM-DE340906)
CAT_EOF
echo ''

setenv ydb_msgprefix "GTM"
setenv ydb_prompt 'GTM>'
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo '# Generate a test routine lock256.m with over 255 locks with the same name'
$gtm_dist/mumps -run %XCMD "do ^lockargsidentical(256)" > lock256.m
echo '# Before GT.M V7.1-000 got merged, this used to result in a SIG-11.'
echo '# Now, this succeeds with no crash, warning, or error.'
echo '# Run lock256.m'
$gtm_dist/mumps -run lock256 >& mumps.out
echo ''
echo '# Generate a test routine lock512.m with over 511 locks with the same name'
$gtm_dist/mumps -run %XCMD "do ^lockargsidentical(512)" > lock512.m
echo '# Before GT.M V7.1-000 got merged, this used to result in a SIG-11.'
echo '# Now, this results in an error that provides additional context, per'
echo '# issue #641: https://gitlab.com/YottaDB/DB/Test/-/issues/641.'
echo '# Run lock512.m'
$gtm_dist/mumps -run lock512 >>& mumps.out
cat mumps.out
$gtm_tst/com/dbcheck.csh
