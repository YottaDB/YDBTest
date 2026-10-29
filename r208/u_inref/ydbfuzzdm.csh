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
# Runs one direct mode case with r208/inref/ydbfuzzdm.m
#
# $1     : the routine in r208/inref that has the case
# $2     : the case, a label in that routine, optionally preceded by -count
# $3 ... : the errors the case is expected to issue, if any
#
# With -count, the expected errors are counted rather than shown, for a case that issues the same error many times.
#
# Writes the input lines of the case to <case>.inp, shows them, feeds them to "mumps -direct" with the output going to
# <case>.out, checks that output against the expectations the case lists, and clears the expected errors from <case>.out
# so that the test framework catches any other error.

set rtn = $1
shift
foreach m (ydbfuzzdm $rtn)
	if (! -e $m.m) cp $gtm_tst/$tst/inref/$m.m .
end
set count = 0
if ("-count" == "$1") then
	set count = 1
	shift
endif
set case = $1
shift
$gtm_dist/mumps -run gen^ydbfuzzdm $rtn $case
set nlines = `wc -l < $case.inp`
echo '# Command : $gtm_dist/mumps -direct < '"$case.inp, where $case.inp has these lines"
if (8 < $nlines) then
	head -n 4 $case.inp | sed 's/^/#   /'
	echo "#   ... ($nlines lines in all)"
else
	sed 's/^/#   /' $case.inp
endif
# A timeout so that a case that hangs without a fix fails instead of hanging the subtest
timeout -k 10 120 $gtm_dist/mumps -direct < $case.inp >& $case.out
$gtm_dist/mumps -run chk^ydbfuzzdm $rtn $case
if (! $#argv) exit
if ($count) then
	# check_error_exist.csh output quotes the errors, so it goes to a .logx file, which the test framework does not scan
	$gtm_tst/com/check_error_exist.csh $case.out $argv:q >& $case.errors.logx
	if ($status) cat $case.errors.logx
	foreach err ($argv:q)
		echo "# $err was issued "`$grep -c -E "$err" ${case}.outx`" times"
	end
else
	$gtm_tst/com/check_error_exist.csh $case.out $argv:q
endif
