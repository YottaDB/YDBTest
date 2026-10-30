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
echo '# [YDB#1347] An argumentless or exclusive NEW in $ZTRAP or device EXCEPTION code for an error in a   #'
echo "# routine compiled with -noline_entry works correctly when the line is retried                       #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# An argumentless or exclusive NEW in $ZTRAP or device EXCEPTION code creates a new symbol table and'
echo '# clears the local variable slots of the routine frame where the error happened. The line with the'
echo '# error is then retried. A routine compiled with -noline_entry fills those slots only at the start of'
echo '# a line with a label, so the retried line used an empty slot and the process terminated with a'
echo '# SIG-11.'
echo '# The subtest compiles r208/inref/ydb1347.m with -noline_entry as ydb1347, and with -line_entry as'
echo '# ydb1347le. Each stage runs its case in a new process. The results with -noline_entry must be the'
echo '# same as with -line_entry.'
echo

cp $gtm_tst/$tst/inref/ydb1347.m .
cp ydb1347.m ydb1347le.m
echo '# Command : $gtm_dist/mumps -noline_entry ydb1347.m'
$gtm_dist/mumps -noline_entry ydb1347.m
echo '# Command : $gtm_dist/mumps -line_entry ydb1347le.m'
$gtm_dist/mumps -line_entry ydb1347le.m
echo

set stage = 0
foreach case (argless^ydb1347 exclusive^ydb1347 laterline^ydb1347 device^ydb1347 dmode argless^ydb1347le device^ydb1347le)
	@ stage++
	switch ($case)
	case "argless^ydb1347":
		echo "# Stage $stage : -noline_entry, "'$ZTRAP="new  set x=1" for an LVUNDEF of x'
		echo '# Before the fix : a SIG-11 when the line was retried'
		echo '# With the fix   : expect the retried line to write x=1, then the caller to continue'
		breaksw
	case "exclusive^ydb1347":
		echo "# Stage $stage : -noline_entry, "'$ZTRAP="new (y) set x=y" with y=5, for an LVUNDEF of x'
		echo '# Before the fix : a SIG-11 when the line was retried'
		echo '# With the fix   : expect the retried line to write x=5, then the caller to continue'
		breaksw
	case "laterline^ydb1347":
		echo "# Stage $stage : -noline_entry, the LVUNDEF on the second line after the label, after SET z=1"
		echo '# Before the fix : a SIG-11 when the line was retried'
		echo '# With the fix   : expect the retried line to write x=1 and $get(z) empty, as z was set in the old'
		echo '#                  symbol table'
		breaksw
	case "device^ydb1347":
		echo "# Stage $stage : -noline_entry, OPEN f of a file that does not exist with EXCEPTION="'"new  set x=1"'
		echo '# Before the fix : a SIG-11 when the OPEN was retried'
		echo '# With the fix   : expect the retried OPEN to issue LVUNDEF for f, caught by $ETRAP, then the caller'
		echo '#                  to continue'
		breaksw
	case "dmode":
		echo "# Stage $stage : -noline_entry, the case of stage 1 from Direct Mode"
		echo '# Before the fix : a SIG-11 when the line was retried'
		echo '# With the fix   : expect the retried line to write x=1, then Direct Mode to continue'
		breaksw
	case "argless^ydb1347le":
		echo "# Stage $stage : -line_entry, the case of stage 1"
		echo '# Before the fix : the same result (this stage is a control)'
		echo '# With the fix   : expect the retried line to write x=1, then the caller to continue'
		breaksw
	case "device^ydb1347le":
		echo "# Stage $stage : -line_entry, the case of stage 4"
		echo '# Before the fix : the same result (this stage is a control)'
		echo '# With the fix   : expect the retried OPEN to issue LVUNDEF for f, caught by $ETRAP, then the caller'
		echo '#                  to continue'
		breaksw
	endsw
	if ("dmode" == "$case") then
		echo 'set $ztrap="new  set x=1" do r1^ydb1347 write "back from r1",!' > dmode.inp
		echo '# Command : $gtm_dist/mumps -direct < dmode.inp'
		$gtm_dist/mumps -direct < dmode.inp |& grep -v '^$' | grep -v '^\(YDB\|GTM\)>$'
	else
		echo '# Command : $gtm_dist/mumps -run '"$case"
		$gtm_dist/mumps -run $case
	endif
	echo
end
echo "# Done"
