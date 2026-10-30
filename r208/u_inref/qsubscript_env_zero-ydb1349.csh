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
echo '# [YDB#1349] $QSUBSCRIPT(), $QLENGTH(), $NAME() and $ZCOLLATE() parse a global name whose second     #'
echo '# environment part is 0 or a $CHAR() correctly                                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# When the second part of the environment of a global name was the number 0 (for example ^[1,0]a(5))'
echo '# or a $CHAR() or $ZCHAR(), the parser of the name recorded an end offset with no start offset for it,'
echo '# so every later component got the wrong offsets. $QSUBSCRIPT() returned ^ as the name and wrong'
echo '# subscripts, $ZCOLLATE() issued DBBADNSUB, and a Debug build failed an assert in is_canonic_name.c.'
echo '# Each stage runs its checks in a new process and prints PASS or WRONG.'
echo

cp $gtm_tst/$tst/inref/ydb1349.m .
foreach label (envzero envzerozero envchar name zcollate unchanged)
	switch ($label)
	case "envzero":
		echo '# Stage 1 : $QLENGTH() and $QSUBSCRIPT() of ^[1,0]a(5)'
		echo '# Before the fix : the name ^ and an empty subscript (Release), or an assert failure (Debug)'
		echo '# With the fix   : expect the name ^a and the subscript 5'
		breaksw
	case "envzerozero":
		echo '# Stage 2 : $QLENGTH() and $QSUBSCRIPT() of ^[0,0]a(5,6)'
		echo '# Before the fix : the name ^ and empty subscripts (Release), or an assert failure (Debug)'
		echo '# With the fix   : expect the name ^a and the subscripts 5 and 6'
		breaksw
	case "envchar":
		echo '# Stage 3 : $QLENGTH() and $QSUBSCRIPT() of ^[1,$C(65)]a(5), ^[1,$ZCH(65)]a(5) and ^[1,"x"_$C(66)]a(5)'
		echo '# Before the fix : the name ^ and an empty subscript (Release), or an assert failure (Debug)'
		echo '# With the fix   : expect the name ^a and the subscript 5'
		breaksw
	case "name":
		echo '# Stage 4 : $NAME(@n,1) and $NAME(@n,0) of ^[1,0]a(5,6), and $NAME(@n,1) of ^[1,$C(65)]a(5,6)'
		echo '# Before the fix : the right results in a Release build, and an assert failure in a Debug build'
		echo '# With the fix   : expect the name with the environment and the first subscript (or none)'
		breaksw
	case "zcollate":
		echo '# Stage 5 : $ZCOLLATE() and $VIEW("YGVN2GDS") of ^[1,0]a(5,6), converted back to a name'
		echo '# Before the fix : DBBADNSUB (Release), or an assert failure (Debug), so the lines below were WRONG'
		echo '#                  lines'
		echo '# With the fix   : expect ^a(5,6) for both'
		breaksw
	case "unchanged":
		echo '# Stage 6 : $QLENGTH() and $QSUBSCRIPT() of names whose environment gave the right results before'
		echo '# Before the fix : the same result (this stage is a control)'
		echo '# With the fix   : expect the right results'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"$label"'^ydb1349'
	$gtm_dist/mumps -run $label^ydb1349
	echo
end
echo "# Done"
