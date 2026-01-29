#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024-2026 YottaDB LLC and/or its subsidiaries.	#
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
YDB254 - Test the following issues
********************************************************************************************

########
Issue 1:
########

\$VIEW("STATSHARE") changes from 0 to 1 after a region-specific VIEW "NOSTATSHARE" command.

########
Issue 2:
########

Newly opened regions implicitly share even after a region-specific VIEW "NOSTATSHARE" or VIEW "STATSHARE" command whereas the release note for GTM-8874 clearly states that "after a VIEW specifies selective sharing, regions don't implicitly share as they open".

########
Issue 3:
########

\$VIEW("STATSHARE") should differentiate whether most recent VIEW "STATSHARE" or VIEW "NOSTATSHARE" command had region list or not.

Currently \$VIEW("STATSHARE") returns 1 if the most recent VIEW "STATSHARE" or VIEW "NOSTATSHARE" command was either a VIEW "STATSHARE" or VIEW "STATSHARE":reglist or VIEW "NOSTATSHARE":reglist. The only reason when \$VIEW("STATSHARE") returns 0 is if the most recent command was a VIEW "NOSTATSHARE". But this is user-unfriendly. It would be better if \$VIEW("STATSHARE") returns 0 if the most recent command was a VIEW:"NOSTATSHARE", returns 1 if the most recent command was a VIEW "STATSHARE", returns 2 if the most recent command was a VIEW "STATSHARE":reglist or VIEW "NOSTATSHARE":reglist.

########
Issue 4:
########

\$VIEW("STATSHARE",reglist) fails with a SIG-11 if a VIEW "NOSTATSHARE":reglist was done previously.

CAT_EOF
echo

set backslash_quote

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps 2 >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
echo

echo "##############"
echo 'Test issue 1:'
echo '$VIEW("STATSHARE") does not change after a region-specific VIEW "NOSTATSHARE" command, but returns the value of gtm_statshare.'
echo
echo 'Runs the ydb254a^ydb254 label to print the results of $VIEW("STATSHARE") both before and after running VIEW "NOSTATSHARE".'
echo 'Two cases are covered:'
echo '1. Expect "00" when run with gtm_statshare UNSET, confirming that VIEW "NOSTATSHARE" does not incorrectly override gtm_statshare=0'
echo '2. Expect "11" when run with gtm_statshare SET, confirming that VIEW "NOSTATSHARE" does not incorrectly override gtm_statshare=1'
echo "##############"
echo "# Run ydb254a^ydb254 label"
$gtm_dist/mumps -run ydb254a^ydb254 >& ydb254a.out
cat ydb254a.out
echo

cat << CAT_EOF
##############
Test issue 2:
Stats are shared after VIEW specifies selective sharing.
This behavior is technically incorrect, but is nevertheless retained in both GT.M and YottaDB.
For details see:
1. https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2544#note_3021345237
2. https://gitlab.com/YottaDB/DB/YDBTest/-/merge_requests/2544#note_3045797187

Test by running the ydb254b^ydb254 label to:
1. Selectively set 'nostatshare' on a region
2. List the directory and store the output to ydb254b-before.out
3. Access a variable from another region
4. List the directory and store the output to ydb254b-after.out

Two cases are covered:
1. Expect "0" when gtm_statshare=0
2. Expect "1" when gtm_statshare=1

In the first case, expect an empty diff between ydb254b-before.out and ydb254b-after.out,
signifying that no .gst file was created when accessing a variable between directory listings.

In the second case, expect a one-line diff between ydb254b-before.out and ydb254b-after.out,
containing a .gst file that was created when accessing a variable between directory listings.

When encryption is randomly enabled for the test, expect also an additional directory
listing for a pipe created during the encryption process.
##############
CAT_EOF
echo "# Run ydb254b^ydb254 label"
$gtm_dist/mumps -run ydb254b^ydb254
grep '\.gst$' ydb254b-before.log >&! ydb254b-before.out
grep '\.gst$' ydb254b-after.log >&! ydb254b-after.out
diff ydb254b-before.out ydb254b-after.out | sed 's/^[0-9]*a[0-9]*$/LINENUM/g'
echo

echo "##############"
echo 'Test issue 3:'
echo '$VIEW("STATSHARE") issues varying return values depending on what variation of'
echo 'VIEW "[NO]STATSHARE" was run beforehand. The ydb254c^ydb254 label tests each of'
echo 'the following four cases by running the VIEW command then calling $VIEW("STATSHARE"):'
echo '1. VIEW "NOSTATSHARE" -> Outputs 0, since stats are not shared'
echo '2. VIEW "STATSHARE" -> Outputs 1, since stats are shared'
echo '3. VIEW "STATSHARE":reglist -> Outputs 2, since stat sharing is selectively enabled for the specified regions'
echo '4. VIEW "NOSTATSHARE":reglist -> Outputs 2, since stat sharing is selectively disabled for the specified regions'
echo
echo 'Previously, $VIEW("STATSHARE") returned:'
echo '1. 0 when run after VIEW "NOSTATSHARE"'
echo '2. 1 in all other cases.'
echo "##############"
echo "# Reset gtmgbldir"
echo "# Run ydb254c^ydb254 label"
$gtm_dist/mumps -run ydb254c^ydb254 >& ydb254c.out
cat ydb254c.out
echo

echo "##############"
echo "Test issue 4:"
echo '$VIEW("STATSHARE",reglist) succeeds and returns "0" when run after VIEW "NOSTATSHARE":reglist.'
echo 'Previously, running $VIEW("STATSHARE", reglist) after VIEW "NOSTATSHARE":reglist resulted in a SIG-11.'
echo "##############"
echo "# Run ydb254d^ydb254 label"
$gtm_dist/mumps -run ydb254d^ydb254 >& ydb254d.out
cat ydb254d.out
echo

$gtm_tst/com/dbcheck.csh
