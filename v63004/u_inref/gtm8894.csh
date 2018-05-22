#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# all rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license. If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################


echo '# Generating output for $zreldate'
$ydb_dist/mumps -run gtm8894 >& temp.out
set x = `cat temp.out`
echo '# Verify output is in libyottadb.so'
strings  $ydb_dist/libyottadb.so | $grep "$x"


