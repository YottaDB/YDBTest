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
echo "# [YDB#1354] ^%ZSHOWVTOLCL restores a local variable node with a string subscript and a string       #"
echo "# value, or a subscript that contains an equal sign                                                  #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# ^%ZSHOWVTOLCL splits each ZSHOW "V" line, for example %GTM("p")="", into the local variable'
echo '# reference (%GTM("p"), the name and its subscripts) and the value (""), at the first "=" that is not'
echo '# within quotes. Before the fix, ^%ZSHOWVTOLCL reported "Could not extract a valid key" and did not'
echo '# restore the variable for a node with a string subscript and a string value, because the quote count'
echo '# included the quote that starts the value, and for some nodes with a subscript that contains "=",'
echo '# because the first quote after an "=" within quotes was taken to be an opening quote. Each case'
echo '# stores one ZSHOW "V" line in ^zv, restores the line with $$^%ZSHOWVTOLCL("^zv") in a frame with no'
echo '# other local variables, and prints PASS if $$^%ZSHOWVTOLCL returns 1 and ZSHOW "V" then shows the'
echo '# same line.'
echo

cp $gtm_tst/$tst/inref/ydb1354.m .

echo '# Create a database with a record size of 256, so that ZSHOW "V" splits long values in stage 4'
echo '# Command : $gtm_tst/com/dbcreate.csh mumps 1 64 256 1024'
$gtm_tst/com/dbcreate.csh mumps 1 64 256 1024 >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
	exit 1
endif
echo

foreach label (quote equal other random)
	switch ($label)
	case "quote":
		echo '# Stage 1 : a string subscript and a string value'
		echo '# Before the fix : "Could not extract a valid key" for all 4, which were not restored'
		echo '# With the fix   : expect each variable to be restored'
		breaksw
	case "equal":
		echo '# Stage 2 : a subscript contains "="'
		echo '# Before the fix : "Could not extract a valid key" for x("a=b")=1, which was not restored, and the'
		echo '#                  other two restored'
		echo '# With the fix   : expect each variable to be restored'
		breaksw
	case "other":
		echo '# Stage 3 : quotes or "=" elsewhere in the line'
		echo '# Before the fix : the same result (this stage is a control)'
		echo '# With the fix   : expect each variable to be restored'
		breaksw
	case "random":
		echo '# Stage 4 : 1000 times, ZSHOW "V" of up to 4 random nodes of a local variable, with names and values'
		echo '#           made of =, ", (, ), comma, a, 1 and space, then restore them'
		echo '# Before the fix : "Could not extract a valid key" and WRONG within the first few times'
		echo '# With the fix   : expect $$^%ZSHOWVTOLCL to return 1 and ZSHOW "V" after the restore to match'
		echo '#                  ZSHOW "V" before it every time'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1354'
	$gtm_dist/mumps -run $label^ydb1354
	echo
end

$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif
echo "# Done"
