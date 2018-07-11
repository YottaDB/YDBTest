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
@ maxgblbufcount=2147483648
@ maxgde=2097152
$gtm_tst/com/dbcreate.csh mumps 1 >>& dbcreate.out
$GDE change -segment DEFAULT -access_method=BG >& accessmethod.out
if ($status) then
	echo "# UNABLE TO CHANGE ACCESS METHOD"
endif
# Maximum global buffers YottaDB supports is 2147483647
echo ""
echo "# TEST CHANGING BUFFERCOUNT VIA GDE"
$GDE change -segment DEFAULT -GLOBAL_BUFFER_COUNT=$maxgblbufcount
echo "# TEST CHANGING BUFFERCOUNT VIA MUPIP"
$MUPIP Set -REGION DEFAULT -GLOBAL_BUFFERS=$maxgblbufcount
$gtm_tst/com/dbcheck.csh >>& dbcheck.out
