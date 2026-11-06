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
GTM-9855 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-004_Release_Notes.html#GTM-DE197637855)

READ * from a socket returns minus one (-1) if the read fails; previously it returned a zero (0) in that case, which was inconsistent with other devices and with the standard. (GTM-9855)

CAT_EOF
echo

$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out

echo "## Run [gtm9855.m] routine to test the return value of a failed READ * command"
$gtm_dist/mumps -r gtm9855

$gtm_tst/com/dbcheck.csh mumps >& dbcheck.out
