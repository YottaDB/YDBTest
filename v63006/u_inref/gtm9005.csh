#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
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

echo '# MUPIP LOAD returns non-zero exit status for load errors'
echo '# Previously in some cases it inappropriately returned a 0 (Zero) exit status when it had been unable to load one or more records.'

$gtm_tst/com/dbcreate.csh yottadb
setenv gtmgbldir yottadb.gld

cat >> load.zwr << xx
10     chars
ZWR 10 chars
^aa=1
^bb=1
^cc=1
^d d=1
^ee=1
^f f=1
xx
if ( "1" == $?gtm_chset ) then
	if ( "UTF-8" == $gtm_chset ) then
		sed -i "1cUTF-8 10 chars" load.zwr
	endif
endif

echo '# Trying to load zwrite file with errors in it'
echo 'Contents of file:'
cat load.zwr
echo '# Loading should get error status of 18'
$ydb_dist/mupip load load.zwr
set pipStatus = $status
if ("18" == $pipStatus) then
	echo 'PASS: $status is correctly 18'
else
	echo 'FAIL: $status is incorrect Expected: 18; Actual: '$pipStatus
endif

$gtm_tst/com/dbcheck.csh

