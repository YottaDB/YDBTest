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
GTM-DE340950 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-000_Release_Notes.html#GTM-DE340950)

An attempt by a process to incrementally LOCK the same resource name more than 511 times produces a LOCKINCR2HIGH with accurate context. Previously LOCK processing did not appropriately detect the limit or supply correct context. (GTM-DE340950)
CAT_EOF
echo ''

setenv ydb_msgprefix "GTM"
setenv ydb_prompt "GTM>"
echo "# Create database file"
$gtm_tst/com/dbcreate.csh mumps
echo
echo "# Test 1: Increment a lock up to 510, then increment by 2 more to a total of 512, exceeding the 511 limit"
echo "# Expect:"
echo "#   1. A LOCKINCR2HIGH error"
echo "#   2. ZSHOW 'L' to show a lock level of 510"
echo "# Prior to v71000:"
echo "#   1. This did NOT issue a LOCKINCR2HIGH error, even though the 511 lock limit was exceeded"
echo "#   2. Doing a ZSHOW 'L' after these operations incorrectly showed that the lock was NOT held"
echo "# See discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/641#note_2359000888 for more detail."
$gtm_dist/mumps -run gtmde340950a^gtmde340950 >>& gtmde340950a.txt
cat gtmde340950a.txt
echo
echo "# Test 2: Increment a lock in groups of 255 until the limit of 511 is exceeded"
echo "# Expect:"
echo "#   1. A LOCKINCR2HIGH error"
echo "#   2. ZSHOW 'L' to show a lock level of 255, for the first call of the lock255 routine"
echo "#   3. ZSHOW 'L' to show a lock level of 510, for the second call of the lock255 routine"
echo "# Prior to v71000:"
echo "#   1. This did NOT issue a LOCKINCR2HIGH error, even though the 511 lock limit was exceeded"
echo "#   2. Doing a ZSHOW 'L' after these operations showed an incorrect lock level"
echo "# See discussion at https://gitlab.com/YottaDB/DB/YDBTest/-/issues/641#note_2356949033 for more detail."
echo "lock255 ;" >& lock255.m
echo -n " lock +(" >>& lock255.m
foreach i (`seq 1 254`)
	echo -n "a," >>& lock255.m
end
echo "a)" >>& lock255.m
echo " quit" >>& lock255.m
$gtm_dist/mumps -run gtmde340950b^gtmde340950 >>& gtmde340950b.txt
cat gtmde340950b.txt
$gtm_tst/com/dbcheck.csh
