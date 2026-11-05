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
echo '# [YDB#1101] A ZTSTART trigger lookup or an INTEG of a doubly allocated block does not assert        #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the commands shown in a new process on a new database, and checks that the output'
echo '# has no fatal error and has the lines expected.'
echo

# The input lines of stages 1 and 2 (written with echo, as a tcsh here document with a quoted delimiter does not end)
echo 'ztstart' > stage1.inp
echo 'zprint ^x#' >> stage1.inp
echo 'zbreak ^x#:"write 1"' >> stage1.inp
echo 'write "end",!' >> stage1.inp
echo 'ztstart' > stage2.inp
echo 'zprint ^x#' >> stage2.inp
echo 'write $text(^x#),!' >> stage2.inp
echo 'write "end",!' >> stage2.inp
foreach stage (1 2 3 4)
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	switch ($stage)
	case 1:
		echo '# Stage 1 : two lookups of a trigger routine (ZPRINT, then ZBREAK) inside ZTSTART'
		set before = ('a Debug build failed an assert in trigger_source_read_andor_verify.c at the second' \
			'lookup')
		set expect = ('TPMIXUP' 2)
		breaksw
	case 2:
		echo '# Stage 2 : the same with ZPRINT, then $TEXT() (which returns an empty string)'
		set before = ('a Debug build failed an assert in trigger_source_read_andor_verify.c at the second' \
			'lookup')
		set expect = ('TPMIXUP' 1)
		breaksw
	case 3:
		echo '# Stage 3 : MUPIP INTEG of a database whose root block of ^a points to itself (made with DSE'
		echo '# OVERWRITE)'
		set before = ('a Debug build of MUPIP failed an assert in bml_busy.c')
		set expect = ('DBBDBALLOC' 1)
		breaksw
	case 4:
		echo '# Stage 4 : MUPIP INTEG of the same database without the DSE OVERWRITE'
		set before = ('No errors detected by integ (this stage is a control)')
		set expect = ('No errors detected by integ' 1)
		breaksw
	endsw
	if (2 >= $stage) then
		echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
		sed 's/^/#   /' ../stage$stage.inp
		$gtm_dist/mumps -direct < ../stage$stage.inp >& stage$stage.out
	else
		$gtm_dist/mumps -run %XCMD 'set ^a(1)=1'
		if (3 == $stage) then
			# The root block of ^a is the first block of the global tree path that FIND -KEY reports. Make the star
			# record of the root block (offset 14 hex: the pointer after the 4-byte record header) point to the root
			# block. The root block number is below 16, so one hexadecimal byte is enough.
			echo 'find -key=^a(1)' > find.dse
			$gtm_dist/dse < find.dse >& find.out
			set root = `$grep -a -A2 "Global tree path" find.out | tail -1 | sed 's/^[ \t]*//;s/:.*//'`
			echo "overwrite -block=$root -offset=14 -data="'"\0'"$root"'"' > overwrite.dse
			$gtm_dist/dse < overwrite.dse >& overwrite.out
		endif
		echo '# Command : $gtm_dist/mupip integ -region DEFAULT'
		$gtm_dist/mupip integ -region DEFAULT >& stage$stage.out
	endif
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : expect $expect[1] $expect[2] time(s)"
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set n = `$grep -c -- "$expect[1]" stage$stage.out`
	if ("$expect[2]" == "$n") then
		echo "PASS : stage$stage.out has $expect[1] $n time(s)"
	else
		echo "FAIL : stage$stage.out has $expect[1] $n time(s), but $expect[2] were expected"
	endif
	if (2 >= $stage) then
		if (1 == `$grep -c -x "end" stage$stage.out`) then
			echo "PASS : the last line of input ran"
		else
			echo "FAIL : the last line of input did not run - see stage$stage/stage$stage.out"
		endif
		$gtm_tst/com/check_error_exist.csh stage$stage.out TPMIXUP >& /dev/null
	else if (3 == $stage) then
		$gtm_tst/com/check_error_exist.csh stage$stage.out DBBDBALLOC INTEGERRS DBLOCMBINC DBMRKBUSY >& /dev/null
	endif
	cd ..
	echo
end
echo "# Done"
