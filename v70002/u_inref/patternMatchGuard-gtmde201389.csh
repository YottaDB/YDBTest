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

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-DE201389 - Test the following release note
*****************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637469) says:

> GT.M pattern match reports a PATMAXLEN error for a deeply
> nested pattern containing many indefinite ranges (. symbols).
> While we think it unlikely, it is possible that existing
> complex patterns may now report this error. Previously such a
> deeply nested pattern terminated with a segmentation violation
> (SIG-11). (GTM-DE201389)

Test case source: https://gitlab.com/YottaDB/DB/YDBTest/-/issues/582#note_1879490491

The test should produce a PATMAXLEN error. Symptoms with
earlier versions:

GT.M V7.0-001 Debug build:
> error caught: %GTM-E-STACKCRIT, Stack space critical

YottaDB r2.00 Debug build:
> Fatal signal: Segmentation fault
> Segmentation fault (core dumped)
CAT_EOF
echo ""

setenv ydb_msgprefix "GTM"
echo "# Creating extreme pattern and performing a match against it"
$gtm_dist/mumps -run genpattern^patternMatchGuard
