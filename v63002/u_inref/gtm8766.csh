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
#
#
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
if ($status) then
	echo "DB Create failed"
	cat dbcreate.out
endif
cp mumps.dat mumpsorig.dat # Take a backup of database with default (i.e. small) global buffers for later restore before dbcheck
$GDE change -segment DEFAULT -access_method=BG >& accessmethod.out
if ($status) then
	echo "# UNABLE TO CHANGE ACCESS METHOD"
endif
if ("64" == "$gtm_platform_size") then
	@ smallvalminus1=2097151
	@ smallval=2097152
	set lowerlim="2Mb-1"
else
	@ smallvalminus1=65536
	@ smallval=65537
	set lowerlim="64Kb"
endif

echo "# In the current version, $lowerlim (for $gtm_platform_size bit builds) is the maximum value accepted by both MUPIP and GDE. In previous versions"
echo "# $lowerlim was the max for MUPIP, but a core would be produced for a value greater than or equal to 2GB, and 2GB was the max value for GDE"
foreach val ($smallvalminus1 $smallval 2147483647 2147483648)

	echo ""
	echo "# CHANGING THE BUFFER COUNT TO $val"
	echo ""
	echo "# TEST CHANGING BUFFERCOUNT VIA GDE"
	$GDE change -segment DEFAULT -GLOBAL_BUFFER_COUNT=$val
	echo "# TEST CHANGING BUFFERCOUNT VIA MUPIP"
	$MUPIP Set -REGION DEFAULT -GLOBAL_BUFFERS=$val
	echo ""
	echo "----------------------------------------------------------------------------------"
end
# The database file has just now been modified to have a huge # of global buffers.
# It is possible that even though the YottaDB build allowed that maximum global buffer value to be set in the
# database file header, the system where this test runs does not have enough RAM to create a shared memory of that size.
# That would then cause errors like the below in the dbcheck.csh (i.e. mupip integ) call.
#	%YDB-I-TEXT, Error with database shmget
#	%SYSTEM-E-ENO12, Cannot allocate memory
# Therefore bring the global buffer count database to a low value that will work i.e. restore database file from after dbcreate.
#	(before the global buffer count was bumped to a high value).
mv mumps.dat mumpsnew.dat
cp mumpsorig.dat mumps.dat
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "DB Check failed"
	cat dbcheck.out
endif
