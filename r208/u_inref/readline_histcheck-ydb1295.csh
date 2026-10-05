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


# Checks a readline history file for the readline_truncate_fallback-ydb1295 subtest and prints PASS or WRONG.
#	$1 = the history file
#	$2 = the number of lines it must hold
#	$3 = its first line
#	$4 = its last line
#	$5 = if specified, a line it must also hold
set hist = "$1"
set nlines = `wc -l < $hist`
if ($2 == $nlines) then
	echo "PASS: $hist holds $nlines lines"
else
	echo "WRONG: $hist holds $nlines lines, expected $2"
endif
set first = "`head -n 1 $hist`"
if ("$3" == "$first") then
	echo "PASS: its first line is [$first]"
else
	echo "WRONG: its first line is [$first], expected [$3]"
endif
set last = "`tail -n 1 $hist`"
if ("$4" == "$last") then
	echo "PASS: its last line is [$last]"
else
	echo "WRONG: its last line is [$last], expected [$4]"
endif
if (5 <= $#argv) then
	set nfound = `grep -cFx -- "$5" $hist`
	if (0 == $nfound) then
		echo "WRONG: it does not hold the line [$5]"
	else
		echo "PASS: it holds the line [$5]"
	endif
endif
