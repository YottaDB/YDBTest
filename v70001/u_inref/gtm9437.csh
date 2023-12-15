#################################################################
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-9437 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-001_Release_Notes.html#GTM-9437)

Making a socket current in a SOCKET device with "USE dev:SOCKET=handle" is now significantly faster
when no other device parameters are specified.Previously, the operation was slowed down by preparations
needed by other device parameters. In addition, USE ATTACH and USE DETACH issue an error if additional
device parameters are specified. Previously, they silently ignored the extra device parameters. (GTM-9437)

CAT_EOF

echo "###########################################################################################"
echo "# Test 1 : USE dev:SOCKET=handle is now significantly faster when no other device parameters are specified".
echo
echo "# This was verified manually and is not easily automatable."
echo "# See https://gitlab.com/YottaDB/DB/YDBTest/-/issues/563#note_1696954117 for more details.".
echo

echo "###########################################################################################"
echo "# Test 2 : Verify USE ATTACH and USE DETACH issue error if additional device parameters are specified"
echo

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif

$gtm_dist/mumps -run gtm9437

echo "# Do dbcheck on database"
$gtm_tst/com/dbcheck.csh >& dbcheck.out
if ($status) then
	echo "# dbcheck failed. Output of dbcheck.out follows"
	cat dbcheck.out
	exit -1
endif

