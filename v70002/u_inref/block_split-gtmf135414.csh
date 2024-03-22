#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
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
GTM-F135414 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-002_Release_Notes.html#GTM-DE197637426)

By default, GT.M proactively splits blocks when it detects significant restarts in an attempt to reduce overall
restarts. MUPIP SET -FILE mumps.dat -PROBLKSPLIT=N where N is 0 disables proactive splitting, as do very large values
of N. Values of N greater than 0 adjust the lower limit for the number of records below which GT.M does not consider
splitting a block. While this is behavior is aimed at reducing restarts, because it reduces data density, it may also
increase the number of blocks and even the tree depth. (GTM-F135414)

CAT_EOF
setenv ydb_msgprefix "GTM"
echo ''
echo '# Create database file'
$gtm_tst/com/dbcreate.csh mumps
echo ''
echo '# See https://gitlab.com/YottaDB/DB/YDBTest/-/issues/575#note_1791619010 for more details'
echo ''
echo '# GT.M V7.0-002 and later splits blocks and when it detects significant restarts'
echo '# So we need to induce restarts for block to be split'
echo '# This test sets PROBLKSPLIT to 3 different value which are 0,1 and 2'
echo '# 0 is for disable block splitting function : Expected data block to not be split at all which is 1'
echo '# 1 means adjust the lower limit for the number of records to 1 : Expected to be the most number of data blocks'
echo '# 2 means adjust the lower limit for the number of records to 2'
echo '# Expect that higher PROBLKSPLIT value will have lower number of data blocks'
echo ''
echo '# Test Proactive block splitting function'
echo ''
echo "Type           Blocks    PROBLKSPLIT"
foreach count (0 1 2)
	$gtm_tst/com/dbcreate.csh mumps$count >& dbcreate_$count.out
	setenv gtmgbldir mumps$count.gld
	$MUPIP set -problksplit=$count -reg "*" >& mupip_set_$count.out
	$gtm_dist/mumps -run split^gtmf135414
	$MUPIP integ -reg "*" |& grep "Data" | cut -b 1-21 | sed 's/$/    '$count'/;'
	endif
end
echo
echo '# Check for database integrity'
$gtm_tst/com/dbcheck.csh


