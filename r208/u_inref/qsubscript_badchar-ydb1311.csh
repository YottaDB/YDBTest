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
echo '# [YDB#1311] $QLENGTH() and $QSUBSCRIPT() issue BADCHAR in UTF-8 mode for a name holding a byte      #'
echo '# sequence that is not a valid UTF-8 character                                                       #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# $QLENGTH() and $QSUBSCRIPT() first check that their argument is a canonic name. In UTF-8 mode that'
echo '# check stepped over each non-ASCII character by the length its first byte implies, and did not check'
echo '# that the bytes form a valid character, so it accepted such a name. $QSUBSCRIPT() then copied the'
echo '# subscript, and for a byte that cannot start a UTF-8 character it wrote past the end of its buffer.'
echo '#'
echo '# $ZCOLLATE(name,0) and $VIEW("YGVN2GDS",name) use the same check, but do not issue BADCHAR, because the'
echo '# reverse $ZCOLLATE(key,0,1) returns a name holding the bytes of a subscript inside quotes as they are.'
echo '#'
echo '# Without the fix, stage 1 prints WRONG for its first $QLENGTH() and then ends the process with a SIG-11'
echo '# (an assert failure in a Debug build) at its first $QSUBSCRIPT(), stage 2 ends the same way at its'
echo '# first $QSUBSCRIPT(), stage 4 prints WRONG with NOCANONICNAME for $ZCH(224), where the step over'
echo '# the byte skips the closing quote, and stages 3 and 5 PASS.'
echo

cp $gtm_tst/$tst/inref/ydb1311.m .
$switch_chset "UTF-8" >& switch_chset_utf8.out

echo '# Stage 1 : UTF-8 mode, VIEW "BADCHAR"'
echo '# Command : $gtm_dist/mumps -run badchar^ydb1311'
echo '#   expect $QLENGTH() and $QSUBSCRIPT() to issue BADCHAR for each name, naming its invalid bytes: a'
echo '#   continuation byte, a byte that is never valid, a first byte followed by a byte that does not'
echo '#   continue it, a first byte followed by the closing quote, a surrogate code point, a bad byte in a'
echo '#   subscript after the one asked for, and a global name'
$gtm_dist/mumps -run badchar^ydb1311
echo

echo '# Stage 2 : UTF-8 mode, VIEW "NOBADCHAR"'
echo '# Command : $gtm_dist/mumps -run nobadchar^ydb1311'
echo '#   expect the same names to be accepted, each subscript to be returned with its bytes unchanged, and'
echo '#   each invalid byte to count as one character in $LENGTH()'
$gtm_dist/mumps -run nobadchar^ydb1311
echo

echo '# Stage 3 : UTF-8 mode, VIEW "BADCHAR", names whose subscripts hold valid 2, 3 and 4 byte characters,'
echo '#           one of them written with a $C() term so $QSUBSCRIPT() copies through its $C() branch too'
echo '# Command : $gtm_dist/mumps -run valid^ydb1311'
echo '#   expect each subscript to be returned unchanged, with each character counting as one in $LENGTH()'
$gtm_dist/mumps -run valid^ydb1311
echo

echo '# Stage 4 : UTF-8 mode, VIEW "BADCHAR", $ZCOLLATE() round trip of a key whose subscript is not valid UTF-8'
echo '# Command : $gtm_dist/mumps -run zcoll^ydb1311'
echo '#   expect the reverse $ZCOLLATE(key,0,1) to return the name with the bytes inside quotes as they are, and'
echo '#   $ZCOLLATE(name,0) and $VIEW("YGVN2GDS",name) to accept that name and return the same key'
$gtm_dist/mumps -run zcoll^ydb1311
echo

$switch_chset M >& switch_chset_m.out
echo '# Stage 5 : Run stage 2 but in M (not UTF-8) mode'
echo '# Command : $gtm_dist/mumps -run mmode^ydb1311'
echo '#   expect each subscript to be returned with its bytes unchanged, each byte counting as one character'
$gtm_dist/mumps -run mmode^ydb1311
echo

echo "# Done"
