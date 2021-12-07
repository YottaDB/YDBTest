#################################################################
#								#
# Copyright (c) 2021-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create a database"
$gtm_tst/com/dbcreate.csh mumps

echo '# Do a %PEEKBYNAME("node_local.max_procs",<region>) expecting a max of 1'
# $ZPIECE is needed to strip out the trailing \0 byte sequence. The trailing \0 byte sequence is due
# to %PEEKBYNAME() printing the full allocation of node_local.max_procs which has space for both the
# largest int4 and the largest int8.
$ydb_dist/yottadb -run %XCMD 'write $ZPIECE($$^%PEEKBYNAME("node_local.max_procs","DEFAULT"),$ZCHAR(0),1)'

echo "# Start an M routine that launches 10 child processes simultaneously in the background"
$ydb_dist/yottadb -run start^ydb758

echo '# Do a %PEEKBYNAME("node_local.max_procs",<region>) expecting to see 11 processes as the max'
echo "# We expect 11 as the max because there are 10 child processes + the parent process"
# $ZPIECE is again needed to strip out the trailing \0 byte sequence for the same reasons as above.
$ydb_dist/yottadb -run %XCMD 'write $ZPIECE($$^%PEEKBYNAME("node_local.max_procs","DEFAULT"),$ZCHAR(0),1)'


echo "# Run a DSE DUMP -FILEHEADER to verify that the maximum processes and timestamp show up"
$ydb_dist/dse dump -fileheader >& dsedump1.out
cat dsedump1.out | grep "Max Concurrent processes"

echo "# Verify that resetting the maximum number of processes via DSE CHANGE -FILEHEADER -RESET_MAX_PROCS works"
$ydb_dist/dse << END >& dsedump2.out
change -fileheader -reset_max_procs
dump -fileheader
END
cat dsedump2.out | grep "Max Concurrent processes"

echo "# Verify that the time was modified to a later timestamp by the DSE CHANGE -FILEHEADER -RESET_MAX_PROCS"
set beforetime = `cat dsedump1.out | grep "Max conc proc time" | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`
set aftertime = `cat dsedump2.out | grep "Max conc proc time" | sed 's@^[^0-9]*\([0-9]\+\).*@\1@'`
if ( $aftertime > $beforetime ) then
	echo "Time was modified correctly by DSE CHANGE -FILEHEADER -RESET_MAX_PROCS"
else
	echo "Time was not modified correctly by DSE CHANGE -FILEHEADER -RESET_MAX_PROCS"
	echo "The timestamp was $beforetime in the first DSE DUMP -FILEHEADER and $aftertime in the second"
endif

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh
