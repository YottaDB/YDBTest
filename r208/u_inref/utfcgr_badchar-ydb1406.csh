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
echo "#--------------------------------------------------------------------------------------------------#"
echo '# [YDB#1406] $FIND() and $EXTRACT() of a string with BADCHARs in UTF-8 mode give the same result   #'
echo '# after an earlier $FIND() or $EXTRACT() of the string as they give without one                    #'
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# In UTF-8 mode, $FIND() with a start position and $EXTRACT() of a string longer than 33 bytes keep a'
echo '# cache of the groups of ASCII characters, multi-byte characters and BADCHARs in the string, which'
echo '# later calls with the same string use. A call that stopped at a BADCHAR left a group in the cache'
echo '# that did not describe the string, and a call whose position was a BADCHAR just after the cached'
echo '# groups, or in a group of BADCHARs cached with VIEW "NOBADCHAR", returned the BADCHAR. So a later'
echo '# call failed an assert, stopped the process with GTMASSERT2 or returned a value where the same call'
echo '# in a new process issues BADCHAR. Each stage below runs in its own process.'
echo

cp $gtm_tst/$tst/inref/ydb1406.m .
$switch_chset "UTF-8" >& switch_chset_utf8.out
foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : $FIND() with start positions 1 to 5 of a string that starts with a BADCHAR, with'
		echo '#           VIEW "BADCHAR", and then $EXTRACT() and $FIND() of the string with VIEW "NOBADCHAR"'
		echo '# Before the fix : BADCHAR for positions 1 and 2, and then, in a Debug build, an assert failure in'
		echo '#                  utfcgr.c for position 3. In a Release build, the lines were as below.'
		echo '# With the fix   : expect BADCHAR for each call with VIEW "BADCHAR", and the BADCHAR as a character'
		echo '#                  with VIEW "NOBADCHAR"'
		breaksw
	case 2:
		echo '# Stage 2 : $EXTRACT() of the third character (the last of three ASCII characters), and then'
		echo '#           $EXTRACT() and $FIND() at and after the fourth character, which is a BADCHAR, with'
		echo '#           VIEW "BADCHAR", and then with VIEW "NOBADCHAR"'
		echo '# Before the fix : $EXTRACT(s,4) returned the BADCHAR and $EXTRACT(s,3,4) returned "c" and the'
		echo '#                  BADCHAR with VIEW "BADCHAR". The other lines were as below.'
		echo '# With the fix   : expect BADCHAR for each call at or after the fourth character with'
		echo '#                  VIEW "BADCHAR", and the BADCHAR as a character with VIEW "NOBADCHAR"'
		breaksw
	case 3:
		echo '# Stage 3 : $EXTRACT() and $FIND() of a string with three BADCHARs after three ASCII characters,'
		echo '#           with VIEW "NOBADCHAR" and then with VIEW "BADCHAR"'
		echo '# Before the fix : after VIEW "BADCHAR", $EXTRACT() of the fourth, fifth and sixth characters each'
		echo '#                  returned the BADCHAR. The other lines were as below.'
		echo '# With the fix   : expect the BADCHAR as a character with VIEW "NOBADCHAR", and after'
		echo '#                  VIEW "BADCHAR", BADCHAR for each call at or after the fourth character'
		breaksw
	case 4:
		echo '# Stage 4 : random $FIND() and $EXTRACT() calls of 500 random strings of ASCII characters, multi-byte'
		echo '#           characters and BADCHARs, with VIEW "BADCHAR" or VIEW "NOBADCHAR" at random. Each call is'
		echo '#           made with the string, which can use the cache of the earlier calls, and with a new copy'
		echo '#           of the string, which has no cache.'
		echo '# Before the fix : an assert failure in utfcgr.c in a Debug build, and GTMASSERT2 in utfcgr.c or'
		echo '#                  calls with different results in a Release build'
		echo '# With the fix   : expect every call to give the same result for the string and for the new copy'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage$stage^ydb1406"
	$gtm_dist/mumps -run stage$stage^ydb1406 >& stage$stage.out
	$grep -E '^(PASS|FAIL|# VIEW) ' stage$stage.out
	echo
end
$switch_chset M >& switch_chset_m.out
