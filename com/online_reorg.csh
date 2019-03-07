#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
$gtm_exe/mumps -run waitforglobal
echo "# `date` : Reorg loop begins"
echo "PID  ""$$"
echo "PID  ""$$" >& mu_reorg_parent.pid
\touch ./REORG.TXT_$$

@ cnt = 1
while (1)
	date
	@ cnt = $cnt + 1
	if (-f REORG.END) then
		break
	endif
	set rand = `$gtm_exe/mumps -run rand 71 2 30`	# Generate 2 random numbers between 30 and 100
	@ ff = $rand[1]
	@ inff = $rand[2]
	if ($cnt == 10) then
		@ cnt = 1
		@ ff = 100
		@ inff = 100
	endif
	set try_nice = ""
	# z/OS use of nice requires some onerous setup on the mainframe side
	if ("HOST_OS390_S390" != $gtm_test_os_machtype) then
		set try_nice = "nice +$gtm_test_nice_level_reorg"
	endif
	# Execute MUPIP REORG -TRUNCATE. Ignore MUTRUNCNOV4 and MUTRUNCNOTBG errors, since we make no effort to restrict -TRUNCATE
	# testing to BG or V5 databases. For V4/V5 in particular, this ensures -TRUNCATE works correctly with changing versions.
	# Limit number of -TRUNCATE iterations. Otherwise journal files can grow quite large because -TRUNCATE never stops
	# moving root blocks around and writing pblks.
	# Every 5th iteration, do mupip size to give it some concurrency testing considering the fact that multiple online_reorgs
	# are called simultaneously
	# The variable *ret* stores exit statuses after each mupip invocation so the test stops in case any sub process exits with error.
	# This is the case for multisrv_crash test case which deliberately kills online_reorg sub processes
	set tmpoutput = "online_reorg_$$.outx.$cnt"
	echo "# `date` : ===== Begin round $cnt of mupip size/reorg ($tmpoutput) ====="
	echo "# `date` : cnt = $cnt ; ff = $ff ; inff = $inff"			>>&!  $tmpoutput
	if ($cnt % 5 == 2) then
		foreach heuristic ("arsample,samples=100000" "impsample,samples=100000" "scan,level=1")
			echo "# `date` : $try_nice $MUPIP size -heuristic=\"$heuristic\""	>>& $tmpoutput
			$try_nice $MUPIP size -heuristic="$heuristic"				>>& $tmpoutput
			set ret = $status
			if ($ret) then
				break
			endif
			# If test has asked us to stop, check for it in between iterations of for loop
			# or else test could wait for too long (as much as 2 hours) for 3 MUPIP SIZE operations to finish
			# causing test to fail with a TEST-E-TIMEOUT error timing out waiting for REORG.TXT* to be removed.
			if (-f REORG.END) then
				break
			endif
		end
	else if ($cnt < 5) then
		echo "# `date` : $try_nice $MUPIP reorg -fill=$ff -index=$inff -truncate"	>>&! $tmpoutput
		$try_nice $MUPIP reorg -fill=$ff -index=$inff -truncate				>>&! $tmpoutput
		set ret = $status
	else
		echo "# `date` : $try_nice $MUPIP reorg -fill=$ff -index=$inff"		>>&! $tmpoutput
		$try_nice $MUPIP reorg -fill=$ff -index=$inff				>>&! $tmpoutput
		set ret = $status
	endif

	$grep -vE "YDB-E-MUTRUNCNOV4|YDB-E-MUTRUNCNOTBG" $tmpoutput
	echo "# `date` : ===== End of round $cnt of mupip size/reorg ====="
	if ($ret) then
		if ($ret != 130) then
			echo "TEST-E-REORG Error: Either REORG was killed, or returned ERROR"
			echo "Return status is: $ret"
			echo "The date is:"
			date
			break
		endif
	endif
end
echo "# `date` : Reorg loop is completed"
\rm -f ./REORG.TXT_$$
