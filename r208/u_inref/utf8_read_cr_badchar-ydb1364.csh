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
echo "# [YDB#1364] READ in UTF-8 mode returns the record that a CR at the end of the READ buffer terminates#"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# READ fills the READ buffer 8192 bytes at a time, and reads the first 3 bytes of a file separately to'
echo '# check for a byte order mark. When a CR line terminator is the last byte in the buffer, READ reads'
echo '# the next character to check whether that character is an LF. Each case of ydb1364.m runs in a new'
echo '# process, writes <n> "x" characters, CR, some bytes and LF to a file, READs the file in UTF-8 mode'
echo '# until $ZEOF, and prints PASS or FAIL for the list of results (L<length of the record> for a READ,'
echo '# E<mnemonic> for a READ that issued an error, EOF for the READ that sets $ZEOF). The READ after the'
echo '# last LF of a file returns an empty record (L0).'
echo

cp $gtm_tst/$tst/inref/ydb1364.m .
$switch_chset "UTF-8" >& switch_chset_utf8.out

foreach stage (1 2 3 4)
	switch ($stage)
	case 1:
		echo '# Stage 1 : CR as the last byte of the first 3 bytes, and of the first and second 8192 bytes after'
		echo '# them, then a byte that is not valid UTF-8 ($ZCHAR(152)), or the first byte of a 2-byte character'
		echo '# followed by a byte that is not a continuation byte ($ZCHAR(195,40))'
		set cases = (1 2 3 4)
		set before = ('a Debug build failed an assert in iorm_readfl.c after the BADCHAR error. A Release' \
			'build gave EBADCHAR L0 L0 EOF (the record that the CR terminates is lost, and an' \
			'extra empty record follows)')
		set with = ('expect the record, then BADCHAR')
		breaksw
	case 2:
		echo '# Stage 2 : CR as the last byte of the first 3 bytes, and of the first 8192 bytes after them, then a'
		echo '# valid 2-byte character ($ZCHAR(195,169))'
		set cases = (5 6)
		set before = ('a Debug build failed an assert in iorm_readfl.c. A Release build gave L2 L0 EOF and' \
			'L8194 L0 EOF (the 2-byte character is lost)')
		set with = ('expect the record, then the 2-byte character')
		breaksw
	case 3:
		echo '# Stage 3 : the same bytes with a CR that is not the last byte in the buffer, and a CR as the last'
		echo '# byte of the first 8192 bytes followed by an ASCII character (Y)'
		set cases = (7 8 9 10 11)
		set before = ('the results that each case expects (this stage is a control)')
		set with = ('expect the results that each case expects')
		breaksw
	case 4:
		echo '# Stage 4 : the same bytes as the first case as Direct Mode input (ab, CR, $ZCHAR(152), LF)'
		echo '# Command : $gtm_dist/mumps -direct < stage4.inp'
		set before = ('BADCHAR, then (in a Debug build) an assert failure in iorm_readfl.c. The line ab' \
			'was not run')
		set with = ('expect INVCMD (the line ab runs as a command), then BADCHAR')
		breaksw
	endsw
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	echo "# With the fix   : $with"
	if (4 == $stage) then
		printf 'ab\r\230\n' > stage4.inp
		$gtm_dist/mumps -direct < stage4.inp >& stage4.out
		if (`$grep -c -- "-F-" stage4.out`) then
			echo "FAIL : stage4.out has a fatal error"
		else
			echo "PASS : no fatal error in stage4.out"
		endif
		set ninvcmd = `$grep -c "INVCMD" stage4.out`
		set nbadchar = `$grep -c "BADCHAR" stage4.out`
		if ((1 == $ninvcmd) && (1 == $nbadchar)) then
			echo "PASS : INVCMD and BADCHAR were issued once each"
		else
			echo "FAIL : INVCMD was issued $ninvcmd times and BADCHAR $nbadchar times, but once each was expected"
		endif
		$gtm_tst/com/check_error_exist.csh stage4.out INVCMD BADCHAR
	else
		foreach case ($cases)
			$gtm_dist/mumps -run ydb1364 $case >& case$case.out
			cat case$case.out
			if (`$grep -c -- "-F-" case$case.out`) then
				echo "FAIL : case$case.out has a fatal error"
			endif
			if (1 != `$grep -c "^PASS" case$case.out`) then
				echo "FAIL : case$case.out does not have a PASS line"
			endif
		end
	endif
	echo
end
echo "# Done"
