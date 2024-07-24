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

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-004_Release_Notes.html#GTM-DE305529)

GT.M maintains the correct value of \$ZTSLATE. Previously, garbage collection could mishandle the ISV
resulting in values not consistent with proper application execution (GTM-DE305529)

CAT_EOF

echo "# Create database (needed for trigger install)"
$gtm_tst/com/dbcreate.csh mumps

echo '# Run [mumps -run gtmde305529]'
$gtm_dist/mumps -run gtmde305529

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh

