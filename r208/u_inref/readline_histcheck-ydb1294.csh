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


# Checks a readline history file for the readline_lazy_load-ydb1294 subtest and prints PASS or WRONG.
#	$1 = absent  : the history file $2 must not exist
#	$1 = present : the history file $2 must exist and hold the line $3
set hist = "$2"
if ("absent" == "$1") then
	if (-e $hist) then
		echo "WRONG: $hist exists, expected it not to"
	else
		echo "PASS: $hist does not exist"
	endif
else
	if (! -e $hist) then
		echo "WRONG: $hist does not exist, expected it to"
	else
		set nlines = `grep -cFx -- "$3" $hist`
		if (0 == $nlines) then
			echo "WRONG: $hist exists but does not hold the line [$3]"
		else
			echo "PASS: $hist exists and holds the line [$3]"
		endif
	endif
endif
