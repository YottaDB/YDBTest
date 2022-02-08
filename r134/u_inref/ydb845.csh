#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# ------------------------------------------------------------------------------------------------'
echo '# Test LKE SHOW output is not garbled for long subscripts and not truncated for lots of subscripts'
echo '# ------------------------------------------------------------------------------------------------'

echo "# Create database"
$gtm_tst/com/dbcreate.csh mumps

@ num = 1
while ($num < 5)
	$ydb_dist/yottadb -run test$num^ydb845 >& test$num.out
	# test$num.out would have lots of repeats. In order to make the reference file readable, use "trimrepeats" on it.
	# To avoid trimming down "----" which repeats 80 times or so in the output, keep minrepeat count at 100 below.
	# In the case of "test3", the output is a sequence of $C(128)_"a"_ so replace that word with a character X and Y
	# before applying "trimrepeats" since the latter only knows to work on characters (not words).
	cat test$num.out	\
		| sed 's/Owned by PID= [0-9]*/Owned by PID= PID/;s/$C(128)_"a"_/X/g;s/$C(128)_"a"/Y/g;'	\
		| $ydb_dist/yottadb -run trimrepeats 80
	if ($num == 1) then
		# Filter out expected failure so test framework does not catch it at the end
		$gtm_tst/com/check_error_exist.csh test$num.out "%YDB-E-LOCKSUB2LONG" >& test$num.outx
	else if ($num == 4) then
		# Filter out expected failure so test framework does not catch it at the end
		$gtm_tst/com/check_error_exist.csh test$num.out "%YDB-E-MAXNRSUBSCRIPTS" >& test$num.outx
	endif
	@ num = $num + 1
end

$gtm_tst/com/dbcheck.csh
