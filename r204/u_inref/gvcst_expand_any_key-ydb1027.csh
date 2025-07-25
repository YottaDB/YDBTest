#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "#--------------------------------------------------------------------------------------------------------------"
echo "# Test MUPIP REORG -MIN_LEVEL=1 does not assert fail in gvcst_expand_any_key.c or fail with a MUREORGFAIL error"
echo "# Test of https://gitlab.com/YottaDB/DB/YDB/-/merge_requests/1724"
echo "# Test case based off https://gitlab.com/YottaDB/DB/YDB/-/issues/1027#note_2651501799"
echo "#---------------------------------------------------------------------------"
echo ''

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps -block_size=1024 -record_size=1000 -key_size=470 >& dbcreate.out
if ($status) then
	echo "# dbcreate failed. Output of dbcreate.out follows"
	cat dbcreate.out
	exit -1
endif
echo ""

echo "# Load 1000s of nodes in ^x with random subscript length and random values"
$gtm_dist/mumps -run %XCMD 'for i=1:1:30000 set ^x($j(i,$random(200)))=$j(i,$random(100))'
echo "# Take backup of mumps.dat BEFORE mupip reorg commands are run just in case it is needed to reproduce a rare failure"
cp mumps.dat bak.dat

echo "# Run 10 iterations of MUPIP REORG -MIN_LEVEL where level =1,2,3 and with random -fill_factor"
echo "# We do not expect any errors from any of the reorg commands"
echo "# Previously (from YDB@8c8975447 to YDB@4d2533c14) this used to fail assert fail (in Debug builds)"
echo "# and fail with MUREORGFAIL (in Release builds)."
echo "# We expect to see a PASS line below."
@ iter = 0
@ failcnt = 0
while ($iter < 10)
	@ iter = $iter + 1
	echo "---> Iteration #$iter" >>& reorg.out
	foreach level (3 2 1)
		set rand = `shuf -i 30-100 -n 1`
		echo "mupip reorg -min_level=$level -fill=$rand -reg *" >>& reorg.out
		$gtm_dist/mupip reorg -min_level=$level -fill=$rand -reg "*" >>& reorg.out
		if ($status) then
			echo "FAIL : MUPIP REORG -MIN_LEVEL=$level failed. See reorg.out for details"
			@ failcnt = 1
		endif
	end
end
if (0 == $failcnt) then
	echo "PASS : All MUPIP REORG -MIN_LEVEL commands returned with 0 exit status"
endif

echo "# Run dbcheck.csh"
$gtm_tst/com/dbcheck.csh
