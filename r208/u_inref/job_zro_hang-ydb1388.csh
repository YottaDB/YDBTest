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
echo '# [YDB#1388] JOB issues JOBFAIL instead of hanging forever when the routine is not in the $ZROUTINES   #'
echo '# of the parent but is in the ydb_routines that the job process starts with                          #'
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# Each stage runs the lines shown in Direct Mode in a new process, and checks that the process ended'
echo '# by itself within 120 seconds, that the output has no fatal error, has the number of JOBFAIL errors'
echo '# expected, and that the last line of input ran. If the process is still running after 120 seconds,'
echo '# the stage kills its JOB middle process (the only child of the process), which ends the hang.'
echo
echo '# Create routine jr.m that the stages JOB, and directory empty, which has no routines'
echo 'jr	open "jr.done":newversion use "jr.done" write $job,! close "jr.done"' > jr.m
echo '	quit' >> jr.m
mkdir empty
# The input lines of each stage (written with echo, as a tcsh here document with a quoted delimiter does not end)
foreach stage (1 2)
	echo 'open "stage'$stage'.pid":newversion use "stage'$stage'.pid" write $job,! close "stage'$stage'.pid"' > stage$stage.inp
end
echo 'set $zroutines="empty"' >> stage1.inp
echo 'job ^jr' >> stage1.inp
echo 'job ^jr' >> stage2.inp
foreach stage (1 2)
	echo 'write "$zjob=",$zjob,!' >> stage$stage.inp
	echo 'write "end",!' >> stage$stage.inp
end
foreach stage (1 2)
	switch ($stage)
	case 1:
		echo '# Stage 1 : JOB a routine that is not in $ZROUTINES but is in ydb_routines (from fuzz testing)'
		set nexp = 1
		set before = ('Debug and Release builds hung forever (the JOB middle process waited for the job' \
			'process, which waited for more job parameters from the middle process)')
		breaksw
	case 2:
		echo '# Stage 2 : JOB the same routine with $ZROUTINES unchanged'
		set nexp = 0
		set before = ('the job process ran (this stage is a control)')
		breaksw
	endsw
	echo '# Command : $gtm_dist/mumps -direct < '"stage$stage.inp, where stage$stage.inp has these lines"
	sed 's/^/#   /' stage$stage.inp
	set label = "# Before the fix :"
	foreach line ($before:q)
		echo "$label $line"
		set label = "#                 "
	end
	if (2 == $stage) then
		echo "# With the fix   : expect no error, and the job process runs"
	else
		echo "# With the fix   : expect $nexp JOBFAIL error, and the job process does not run"
	endif
	rm -f jr.done
	# Create stage$stage.out first, as tcsh runs the grep in the loop below even when stage$stage.pid does not exist,
	# which can be before the background process creates stage$stage.out
	touch stage$stage.out
	($gtm_dist/mumps -direct < stage$stage.inp >& stage$stage.out &) >& /dev/null
	set i = 0
	while (120 > $i)
		if ((-e stage$stage.pid) && (`$grep -Fxc "end" stage$stage.out`)) break
		sleep 1
		@ i = $i + 1
	end
	if (120 > $i) then
		echo "PASS : the process ended by itself"
	else
		echo "FAIL : the process was still running after 120 seconds"
		set ppid = `cat stage$stage.pid`
		set mpid = `ps -o pid= --ppid $ppid`
		if ("" != "$mpid") kill -9 $mpid
		$gtm_tst/com/wait_for_proc_to_die.csh $ppid 120 >& /dev/null
	endif
	if (`$grep -c -- "-F-" stage$stage.out`) then
		echo "FAIL : stage$stage.out has a fatal error"
	else
		echo "PASS : no fatal error in stage$stage.out"
	endif
	set nerr = `$grep -c -- "-E-JOBFAIL," stage$stage.out`
	set nend = `$grep -Fxc "end" stage$stage.out`
	if (($nexp == $nerr) && (1 == $nend)) then
		echo "PASS : JOBFAIL was issued $nerr time(s), and the last line of input ran"
	else
		echo "FAIL : JOBFAIL was issued $nerr times ($nexp expected), and end is there $nend times"
	endif
	if (2 == $stage) then
		# The job process may still be running when the parent writes end, so wait for it to write jr.done
		set i = 0
		while ((! -e jr.done) && (60 > $i))
			sleep 1
			@ i = $i + 1
		end
		set zjob = `$grep '^$zjob=' stage2.out | cut -d= -f2`
		if ((-e jr.done) && ("$zjob" == `cat jr.done`)) then
			echo 'PASS : the job process ran, and its $JOB is the $ZJOB of the parent'
			$gtm_tst/com/wait_for_proc_to_die.csh $zjob 120 >& /dev/null
		else
			echo 'FAIL : the job process did not run, or its $JOB is not the $ZJOB of the parent'
		endif
	else
		if (1 == `$grep -Fxc '$zjob=0' stage$stage.out`) then
			echo 'PASS : $ZJOB is 0'
		else
			echo 'FAIL : $ZJOB is not 0'
		endif
		if (-e jr.done) then
			echo "FAIL : the job process ran"
		else
			echo "PASS : the job process did not run"
		endif
	endif
	if ($nerr) $gtm_tst/com/check_error_exist.csh stage$stage.out JOBFAIL >& /dev/null
	echo
end
