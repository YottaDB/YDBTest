#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "#----------------------------------------------------------------------------------------------------#"
echo '# [YDB#1378] ZYENCODE to a global variable whose chunk node key is longer than the maximum key size  #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# ZYENCODE to a global variable stores the JSON string in chunk nodes, with the chunk number as an'
echo '# added subscript. Each stage runs stage<N>^ydb1378 in a new process on a separate database (maximum'
echo '# key size 64, maximum record size 256), which checks the error that ZYENCODE issues (if any) and what'
echo '# ZYENCODE stored, and then checks the database with MUPIP INTEG (dbcheck.csh).'
echo
foreach stage (1 2 3 4 5 6 7)
	switch ($stage)
	case 1:
		echo '# Stage 1 : ZYENCODE ^gvn=lvn, with a destination key that is too long once the chunk number is added'
		echo '# (from fuzz testing)'
		set before = ('a Debug build failed an assert in op_gvput.c; a Release build stored the node and' \
			'INTEG reported DBGTDBMAX')
		set expect = 'GVSUBOFLOW, nothing stored, no INTEG error'
		breaksw
	case 2:
		echo '# Stage 2 : ZYENCODE ^gvn=^gvn, with the same destination key'
		set before = ('a Debug build failed an assert in op_gvput.c; a Release build stored the node and' \
			'INTEG reported DBGTDBMAX')
		set expect = 'GVSUBOFLOW, nothing stored, no INTEG error'
		breaksw
	case 3:
		echo '# Stage 3 : ZYENCODE of a JSON string of 371 chunks, where only the keys of the later chunks are too'
		echo '# long. The key of the last chunk, ^j(s,371), is 65 bytes, one byte more than the maximum key size.'
		set before = ('a Debug build failed an assert in op_gvput.c; a Release build stored the nodes and' \
			'INTEG reported DBGTDBMAX')
		set expect = 'GVSUBOFLOW for a key of 65 bytes (maximum 64), nothing stored, no INTEG error'
		breaksw
	case 4:
		echo '# Stage 4 : ZYENCODE with the destination of stage 3 and a JSON string of 1 chunk. The key of that'
		echo '# chunk, ^j(s,1), is 64 bytes, exactly the maximum key size.'
		set before = ('ZYENCODE stored the JSON string, and INTEG was clean (this stage is a control)')
		set expect = 'no error, the JSON string stored, no INTEG error'
		breaksw
	case 5:
		echo '# Stage 5 : ZYENCODE ^gvn=lvn as in stage 1, with a subscripted source'
		set before = ('a Debug build failed an assert in op_gvput.c; a Release build stored the node and' \
			'INTEG reported DBGTDBMAX')
		set expect = 'GVSUBOFLOW, nothing stored, no INTEG error'
		breaksw
	case 6:
		echo '# Stage 6 : ZYENCODE ^gvn=^gvn as in stage 2, with a subscripted source'
		set before = ('a Debug build failed an assert in op_gvput.c; a Release build stored the node and' \
			'INTEG reported DBGTDBMAX')
		set expect = 'GVSUBOFLOW, nothing stored, no INTEG error'
		breaksw
	case 7:
		echo '# Stage 7 : ZYENCODE ^gvn=^gvn as in stage 4, so the key of the one chunk, ^j(s,1), is exactly the'
		echo '# maximum key size'
		set before = ('ZYENCODE stored the JSON string, and INTEG was clean (this stage is a control)')
		set expect = 'no error, the JSON string stored, no INTEG error'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage$stage^ydb1378"
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect"
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 -key_size=64 -record_size=256 >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	$gtm_dist/mumps -run stage$stage^ydb1378 >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	endif
	$grep -E "^(PASS|FAIL) " stage$stage.out
	$gtm_tst/com/dbcheck.csh >& dbcheck.out
	if ($status) then
		echo "FAIL : dbcheck.csh failed (database integrity errors) - see stage$stage/dbcheck.out"
	else
		echo "PASS : dbcheck.csh found no database integrity errors"
	endif
	cd ..
	echo
end
