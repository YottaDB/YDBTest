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
echo "# [YDB#1392] USE of a SOCKET device with an empty LISTEN address issues INVPORTSPEC                 #"
echo "#--------------------------------------------------------------------------------------------------#"
echo
echo '# USE of a SOCKET device with LISTEN="" issued ADDRTOOLONG, which said that an address of length 0'
echo '# was longer than the maximum permissible length, while USE with CONNECT="" and OPEN with LISTEN=""'
echo '# issue INVPORTSPEC. Each stage runs in a new process.'
echo

cp $gtm_tst/$tst/inref/ydb1392.m .
foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : USE with LISTEN="" of a socket device that listens on a LOCAL socket'
		echo '# Before the fix : ADDRTOOLONG'
		echo '# With the fix   : expect INVPORTSPEC'
		breaksw
	case 2:
		echo '# Stage 2 : USE with CONNECT="", with a LISTEN address that is too long (128 bytes) and with a'
		echo '#           valid LISTEN address, and OPEN with LISTEN=""'
		echo '# Before the fix : the results below (this stage is a control)'
		echo '# With the fix   : expect the same'
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -run '"stage$stage^ydb1392"
	$gtm_dist/mumps -run stage$stage^ydb1392 >& stage$stage.out
	$grep -E "^(PASS|FAIL) " stage$stage.out
	set nother = `$grep -vcE "^(PASS|FAIL) " stage$stage.out`
	if (0 == $nother) then
		echo "PASS : stage$stage.out has no other line"
	else
		echo "FAIL : stage$stage.out has $nother other lines"
	endif
	echo
end
