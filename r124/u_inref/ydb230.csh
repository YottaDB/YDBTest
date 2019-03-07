#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "---------------------------------------------------------------------------------------------------------------------------"
echo '# Tests that using -1 as the optional parameter for $zsearch() returns the first file match instead of a ZSRCHSTRMCT error.'
echo "---------------------------------------------------------------------------------------------------------------------------"

echo "# Create a set of files to search for"
foreach i( a b c )
	echo "Test" > ydb230_$i.txt
end

echo '# Case 1: Use $zsearch() with a second parameter between 0-255'
set rand_num=`$ydb_dist/mumps -run ^%XCMD 'write $random(256)'`
$ydb_dist/mumps -run case12^ydb230 $rand_num

echo ""
echo '# Case 2: Use $zsearch() with a second parameter of -1, it should print the first file found no matter how many times repeated'
$ydb_dist/mumps -run case12^ydb230 -1

echo ""
echo '# Case 3: Use $zsearch() with a second paramter of 0-9 or -1, and test to see if streams maintain file when randomized.'
# generate and run the randomized m file
$ydb_dist/mumps -run case3^ydb230
$ydb_dist/mumps -run ydb230run >& case3.txt

set randVal=`cat randVal.txt`
echo "Files from Stream -1"
grep "Stream -1"'$' case3.txt | cut -d " " -f 1
foreach stream( 2 3 4 5 6 7 8 9 10 11)
	echo "Files from Random Stream # between 0 and 255 (inclusive)"
	grep "Stream $randVal[$stream]"'$' case3.txt | cut -d " " -f 1
end
