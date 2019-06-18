#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#
#

echo '# Test that SIGINT (Ctrl-C) leaves the database clean using SimpleaAPI/SimpleThreadAPI'

# because excaping in tcsh is rather bad
set DOLLAR='$'
set dq='"'
set ddq=${dq}{$dq}

# this code is copied from simpleapi|simplethreadapi/randomWalk test
# as we want to create the executables but need to run them in a loop
if (`uname -m` == "armv7l" || `uname -m` == "armv6l") then
	set ISARM = "-DISARM=1"
else
	set ISARM = "-DISARM=0"
endif

foreach test ("simpleapi" "simplethreadapi")
	# each test gets a database so that integs from one do not show up in the other
	echo "# $test tests"
	$gtm_tst/com/dbcreate.csh $test
	setenv gtmgbldir $test.gld
	echo "# kill -2 3 randomWalk processes"
	$gt_cc_compiler $gtt_cc_shl_options -I$gtm_tst/com -I$gtm_dist $gtm_tst/$test/inref/randomWalk.c $ISARM -DNO_PRINT=1
	if ( "0" != $status ) then
		echo "Failure compiling $test/randomWalk exiting"
		exit 1
	endif
	$gt_ld_linker $gt_ld_option_output ${test}_randomWalk $gt_ld_options_common randomWalk.o $gt_ld_sysrtns $ci_ldpath$gtm_dist -L$gtm_dist $tst_ld_yottadb $gt_ld_syslibs >& ${test}_randomWalk.map
	if ( "0" != $status ) then
		echo "Failure compiling $test/randomWalk exiting"
		exit 1
	endif
	foreach i (`seq 1 1 3`)
		mkdir $test$i
		ls -1 > filesA.list # make a list of all files that exist before the test starts

		# before each test initialize ^pids(i) so the node can be found via ydb_node_previous_*() in the randomWalk processes.
		$gtm_dist/mumps -run %XCMD "set ^pids($i)=$ddq"
		( `pwd`/${test}_randomWalk & ) >&! $test$i.out
		# sleep to allow randomWalk to do some database operations before SIGINT'ing it
		sleep `shuf -i 1-5 -n 1`

		# kill -2 all the pids stored in ^pids
		$gtm_dist/mumps -run %XCMD "set sub=${DOLLAR}order(^pids($i,${ddq})) write:sub=${ddq} ${dq}FAIL: ^pids has not been set${dq},! for  quit:sub=${ddq}  set tmp=${DOLLAR}zsigproc(sub,2) set sub=${DOLLAR}order(^pids($i,sub))"
		# wait for all the pids to die
		$gtm_dist/mumps -run %XCMD "set sub=${DOLLAR}order(^pids($i,${ddq})) for  quit:sub=${ddq}  hang:${DOLLAR}zgetjpi(sub,${dq}ISPROCALIVE${dq}) 0.01 set:'${DOLLAR}zgetjpi(sub,${dq}ISPROCALIVE${dq}) sub=${DOLLAR}order(^pids($i,sub))"

		# use dbcheck_filter because we want to ignore the benign errors
		# KILLABANDONED, DBLOCMBINC, DBMRKBUSY
		$gtm_tst/com/dbcheck_filter.csh >& dbcheck.out
		if (0 != $status) then
			echo 'FAIL: Database errors found printing log and exiting'
			cat dbcheck.out
			exit 1
		endif

		ls -1 > filesB.list # list of files after the test is over
		# move only the new files to the test$testNum directory
		diff --changed-group-format='%<' --unchanged-group-format='' filesB.list filesA.list | xargs mv -t $test$i
	end
	echo 'PASS: No database errors found'
	echo
end


exit 0
