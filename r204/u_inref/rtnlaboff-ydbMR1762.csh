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
YDB!1762 - Test the following MR comment
********************************************************************************************

!1762 comment 2796401515:

I noticed that the JOBLABOFF error was not very user friendly so changed the name to RTNLABOFF and the error text to be more descriptive of the potential causes.

I had not provided this detail in the commit message but noting it now.

\$ echo " quit" > test.m
\$ \$gtm_dist/mumps -run invalidlabel^test

The above steps issued the following error in YDB master.

> %YDB-E-JOBLABOFF, Label and offset not found in created process

The error did not make sense as there is no created process and there is no JOB and there is no offset.
With !1762 (merged), one would see the following error.

> %YDB-E-RTNLABOFF, Label invalidlabel and/or offset 0 not found in routine test

This identifies the invalid label name invalidlabel and says and/or before the offset indicating the label and or the offset could be incorrect. It also mentions the routine name test. And finally has RTNLABOFF in the message name indicating this is a routine related error. Nothing to do with a JOB command and there is no created process involved in this case.

See the original comment at:  [!1762 (comment 2796401515)](https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1762#note_2796401515).

CAT_EOF
echo

echo "# Create a simple [test.m] routine with no label"
echo " quit" > test.m
echo "# Attempt to run a label that doesn't exist: [invalidlabel^test]"
echo "# Expect RTNLABOFF message. Previously, a JOBLABOFF message was emitted."
$gtm_dist/mumps -run invalidlabel^test
