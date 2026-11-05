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
echo '# [YDB#1371] DSE FIND -KEY reports an error for an index block that points to itself                 #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the DSE commands shown on a database with the nodes shown, and checks that the'
echo '# output has no fatal error, has the lines expected once, and that the DSE command after FIND -KEY'
echo '# ran.'
echo

foreach stage (1 2 3 4 5 6)
	mkdir stage$stage
	cd stage$stage
	$gtm_tst/com/dbcreate.csh mumps 1 >& dbcreate.out
	if ($status) then
		echo "FAIL : dbcreate.csh failed - see stage$stage/dbcreate.out"
	endif
	set nocrit = ""
	switch ($stage)
	case 1:
		echo '# Stage 1 : FIND -KEY=^a(1) after DSE OVERWRITE made the root block of ^a point to itself'
		set key = '^a(1)'
		breaksw
	case 2:
		echo '# Stage 2 : the same as stage 1 with FIND -KEY=^a'
		set key = '^a'
		breaksw
	case 3:
		echo '# Stage 3 : FIND -KEY=^a(1500) on a database without damage, with 2000 nodes of ^a'
		set key = '^a(1500)'
		breaksw
	case 4:
		echo '# Stage 4 : FIND -KEY=^a(1) after DSE CHANGE made the level of the root block of ^a 11 (0xB), the'
		echo '#           maximum number of levels of a tree'
		set key = '^a(1)'
		set newlevel = B
		breaksw
	case 5:
		echo '# Stage 5 : FIND -KEY=^a(1) after DSE CHANGE made the level of the root block of ^a 2, so the data'
		echo '#           block that it points to (level 0) is not one level below it'
		set key = '^a(1)'
		set newlevel = 2
		breaksw
	case 6:
		echo '# Stage 6 : the same as stage 1 with FIND -KEY=^a(1) -NOCRIT (DSE does not get crit for the search, and no'
		echo '#           other process updates the database, so the output is the same as with crit)'
		set key = '^a(1)'
		set nocrit = " -nocrit"
		breaksw
	endsw
	if (3 == $stage) then
		$gtm_dist/mumps -run %XCMD 'for i=1:1:2000 set ^a(i)=$justify(i,200)'
		set expect = ('Key found in block')
		echo "# Before the fix : Key found in block, then the output of FIND -BLOCK=2 (this stage is a control)"
	else
		$gtm_dist/mumps -run %XCMD 'set ^a(1)=1'
		# The root block of ^a is the first block of the global tree path that FIND -KEY reports
		echo 'find -key=^a(1)' > find.dse
		$gtm_dist/dse < find.dse >& find.out
		set root = `$grep -a -A2 "Global tree path" find.out | tail -1 | sed 's/^[ \t]*//;s/:.*//'`
		if ((4 == $stage) || (5 == $stage)) then
			# Change the level of the root block (stage 4 : 11, one more than the deepest level a tree can have,
			# stage 5 : 2, so the level 0 data block under it is not one level below it)
			echo "change -block=$root -level=$newlevel" > change.dse
			$gtm_dist/dse < change.dse >& change.out
			if (4 == $stage) then
				set expect = ('is at level 11, but the highest level of a block is 10.')
			else
				set expect = ('is at level 0, but its parent block 0x')
			endif
			echo '# Before the fix : FIND -KEY reported "Key found in block", as it did not check the level of a block'
		else
			# Make the star record of the root block (offset 14 hex: the pointer after the 4-byte record header)
			# point to the root block. The root block number is below 16, so one hexadecimal byte is enough.
			echo "overwrite -block=$root -offset=14 -data="'"\0'"$root"'"' > overwrite.dse
			$gtm_dist/dse < overwrite.dse >& overwrite.out
			set expect = ('is at level 1, but its parent block 0x')
			echo "# Before the fix : DSE terminated with a SIG-11 (KILLBYSIGSINFO1)"
		endif
	endif
	echo "# Command : DSE with these lines as input"
	echo "find -key=$key$nocrit" > stage$stage.dse
	echo 'find -block=2' >> stage$stage.dse
	sed 's/^/#   /' stage$stage.dse
	echo "# With the fix   : expect $expect,"
	echo "#                  then the output of FIND -BLOCK=2"
	$gtm_dist/dse < stage$stage.dse >& stage$stage.out
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set n = `$grep -c -F -- "$expect" stage$stage.out`
	if (1 == $n) then
		echo "PASS : stage$stage.out has $expect"
	else
		echo "FAIL : stage$stage.out has $expect $n times"
	endif
	# FIND -BLOCK=2 (the directory tree data block) reports the directory path 1:10, which is the last part of the output
	if (`$grep -a -c "1:10," stage$stage.out` >= 2) then
		echo "PASS : FIND -BLOCK=2 ran after FIND -KEY"
	else
		echo "FAIL : FIND -BLOCK=2 did not run after FIND -KEY - see stage$stage/stage$stage.out"
	endif
	cd ..
	echo
end
echo "# Done"
