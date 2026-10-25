#################################################################
#								#
# Copyright (c) 2019-2026 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo '# Test that a fatal signal (randomly uses either SIGINT or SIGTERM) cleanly shuts down YDBGo process with no cores'
echo '# This test uses the threeenp* subtests as sample processes'

# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# Save original ASAN_OPTIONS for use below
if ! ($?ASAN_OPTIONS) setenv ASAN_OPTIONS
set asan_options="$ASAN_OPTIONS"

# we test on each one of the threenp* programs (YDBGo v1) and ydb3n1 (YDBGo v2)
foreach prog (threeenp1B1 threeenp1B2 threeenp1C2 ydb3n1)
	setenv ydb_gbldir $tstpath/$prog.gld
	$gtm_tst/com/dbcreate.csh $prog -gld_has_db_fullpath >>& dbcreate.out || \
	    echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
	echo "# Building $prog"
	$gobuild $gtm_tst/$tst/inref/$prog.go >& go_build.log || \
	    echo "TEST-E-FAILED : Unable to build $prog.go. go_build.log output follows." && cat go_build.log && exit 1
	foreach run (`seq 3`)
		# Generate much more detailed and helpful asan error reports
		setenv ASAN_OPTIONS "${asan_options}:log_path=asan.$prog-$run.log"
		# For threeenp1C2 set $ydb_filepfx_threeenp1C2 properly to create output files with the proper prefix
		set logargs=""
		if ("$prog" == "ydb3n1") set logargs="--outlog=ydb3n1-$run --errlog=ydb3n1-$run"
		if ("$prog" == "threeenp1C2") setenv ydb_filepfx_threeenp1C2 "$prog-$run"
		# Calculating this many sequences takes minutes on pro build and over an hour on a debug asan build.
		# This is important so that the program doesn't finish before it can be killed.
		# ^queued is how ydb3n1 tells when all its workers run (see below), so clear the value the previous run left
		if ("ydb3n1" == "$prog") $gtm_dist/mumps -run %XCMD 'kill ^queued'
		(echo 100000000 | `pwd`/$prog $logargs &) >&! $prog-$run.out
		unsetenv ydb_filepfx_threeenp1C2 # Don't leave it set
		if ($?gtm_tst_quick) then
			sleep 1 # give some time for database processes to occur
		else
			sleep `shuf -i 4-8 -n 1` # give some time for database processes to occur
		endif
		set goPID = ""
		set pathto = `pwd`
		# threeenp1C2 and ydb3n1 launch their worker processes one at a time after their own setup, and the main process
		# keeps launching them after it is signaled, until its next YottaDB call fails. A worker that is not running when
		# the pids are listed below is never signaled. The listing of the next run then finds and signals it, so its
		# FORCEDHALT lands in this run's output file after the filtering below has looked for it. So wait until all the
		# workers run before listing. threeenp1C2 prints its worker count as the second number of its output, and each of
		# its workers writes "doblk started" to its own output file when it starts. Workers are counted by those lines and
		# not by processes, because a worker that finds no block left to process exits at once. ydb3n1 sets ^queued to its
		# worker count, and each worker decrements it once it runs. The main process, which is one of the workers, waits
		# for it to be 1 and then decrements it too, so 1 or 0 means all workers run. threeenp1B1 and threeenp1B2 run
		# goroutines in a single process. This does not cover ydb3n1 --manyworkers, which starts a worker per block.
		set started = 0
		@ waited = 0
		while (300 > $waited)
			switch ($prog)
			case threeenp1C2:
				set nworkers = `$tst_awk 'NR == 1 && NF >= 2 {n = $2} END {print n + 0}' $prog-$run.out`
				set nstarted = `cat /dev/null $prog-$run-*.out |& $grep -c "doblk started"`
				if ((0 < $nworkers) && ($nworkers <= $nstarted)) set started = 1
				breaksw
			case ydb3n1:
				if ("1" == `$gtm_dist/mumps -run %XCMD 'write ($data(^queued)#2)&(2>$get(^queued))'`) set started = 1
				breaksw
			default:
				set started = 1
				breaksw
			endsw
			if ($started) break
			sleep 1
			@ waited++
		end
		if (! $started) echo "TEST-E-FAIL : not all processes of $prog-$run started within $waited seconds"
		echo "Terminating $prog; Run $run"
		# Get pids of all processes we ran. Use [] to ensure grep doesn't find itself in the list of processes
		set goPID = `ps -x | grep "${pathto}[/]$prog" | awk '{print $1}'`
		echo "goPID  $goPID"
		set killsig = `printf 'TERM\nINT' | shuf -n1`
		kill -s ${killsig} $goPID
		# wait_for_proc_to_die.csh only works on one pid at a time
		foreach pid ($goPID)
			$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
		end
		# YDB-E-CALLINAFTERXIT error expected due signal handler  calling ydb_exit() while main is running.
		# In case of signal TERM, FORCEDHALT messages are also expected.
		# Filter these out so the error catching test framework does not see them.
		foreach file ($prog-$run*.out)
			$gtm_tst/com/check_error_exist.csh $file "%YDB-E-CALLINAFTERXIT|%YDB-F-FORCEDHALT" >&! ${file:r}.check.outx
		end
		set asan_failure_count=`find -name "asan.$prog-$run.log.*" | wc -l`
		set asan_message="$asan_failure_count processes failed AddressSanitizer tests when running $prog iteration $run"
		[ "$asan_failure_count" != "0" ] && echo "$asan_message"
	end
	echo "done"
	$gtm_tst/com/dbcheck.csh >& dbcheck$prog.out || \
		echo "# dbcheck failed. Output of dbcheck$prog.out" && cat dbcheck$prog.out
end
