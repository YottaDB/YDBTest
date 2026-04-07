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
		(echo 100000000 | `pwd`/$prog $logargs &) >&! $prog-$run.out
		unsetenv ydb_filepfx_threeenp1C2 # Don't leave it set
		if ($?gtm_tst_quick) then
			sleep 1 # give some time for database processes to occur
		else
			sleep `shuf -i 4-8 -n 1` # give some time for database processes to occur
		endif
		set goPID = ""
		set pathto = `pwd`
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
