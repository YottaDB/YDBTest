#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
$GDE change -segment DEFAULT -access_method=BG >& accessmethod.out
if ($status) then
	echo "# UNABLE TO CHANGE ACCESS METHOD"
endif
if ("64" == "$gtm_platform_size") then
	@ smallvalminus1=2097151
	@ smallval=2097152
	set lowerlim="2Mb"
else
	@ smallvalminus1=65536
	@ smallval=65537
	set lowerlim="64Kb"
endif

echo "# In the current version, $lowerlim is the maximum value accepted by both MUPIP and GDE. In previous versions"
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
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
if ($status) then
	echo "DB Check failed"
	cat dbcheck.out
endif
