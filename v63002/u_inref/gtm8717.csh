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
@ num = 1
@ fail = 0
echo '# Testing 1000 random variations of $select syntax, checking for FATAL errors'
echo ""
echo "# RUNNING TEST"
echo ""
while ($num < 1000)
        $ydb_dist/mumps -run select^gtm8717 > temp$num.m
        $ydb_dist/mumps -run temp$num >& errorcheck$num.outx
	if ("" != `$grep "\-F\-" errorcheck$num.outx`) then
		cat errorcheck$num.outx
		@ fail = $fail + 1
	endif
        @ num = $num + 1
end

echo "# $fail RUNS PRODUCED A FATAL ERROR"
if ($fail) then
	echo "# TEST FAILED"
else
	echo "# TEST PASSED"
endif

$gtm_tst/com/dbcheck.csh >>& dbcheck.out
