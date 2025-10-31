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

# Use -gld_has_db_fullpath to ensure gld is created with full paths pointing to the database file
# (see comment before "setenv ydb_gbldir" done below for why).
#
# Set up the golang environment and sets up our repo
#
# Do our golang setup (sets $tstpath, $PKG_CONFIG_PATH, $GOPATH, $ydbgo_url, $goflags)
source $gtm_tst/com/setupgoenv.csh >& setupgoenv.out || \
	echo "[source $gtm_tst/com/setupgoenv.csh] failed with status [$status]:" && cat setupgoenv.out && exit 1

# we test on each one of the threenp* programs
foreach prog (threeenp1B1 threeenp1B2 threeenp1C2)
	setenv ydb_gbldir $tstpath/$prog.gld
	$gtm_tst/com/dbcreate.csh $prog -gld_has_db_fullpath >>& dbcreate.out || \
	    echo "# dbcreate failed. Output of dbcreate.out follows" && cat dbcreate.out
	# Build our routine (must be built due to use of cgo).
	echo "# Building $prog"
	$gobuild $gtm_tst/$tst/inref/$prog.go >& go_build.log || \
	    echo "TEST-E-FAILED : Unable to build threeenp1B1.go. go_build.log output follows." && cat go_build.log && exit 1
	# this number takes the longest to compute from all numbers [1, 100,000,000]
	# important so that the program doesn't finish before it can be killed
	cat >> seed.input << EOF
63728126
63728126
EOF
	foreach run (`seq 1 1 3`)
		# If this is threeenp1C2, we need to set $ydb_filepfx_threeenp1C2 properly to create output files with the
		# proper prefix
		if ("threeenp1C2" == "$prog") setenv ydb_filepfx_threeenp1C2 "$prog$run"
		echo "Terminating $prog; Run $run"
		(`pwd`/$prog < seed.input &) >&! $prog$run.out
		unsetenv ydb_filepfx_threeenp1C2 # Don't leave it set
		sleep `shuf -i 4-8 -n 1` # give some time for database processes to occur
		# since threeenp1C2 creates multiple processes we need to loop through all the pids
		set goPID = ""
		set pathto = `pwd`
		# filter out "grep" because the first grep command will contain the string to match as an argument
		# the sed is because ps output is not left justifed; when the pid of the process is less than 5 characters
		# the cut command will just return the empty string ""
		foreach pid (`ps -x | grep $pathto/$prog | grep -v "grep" | sed 's/^ *//g' | cut -f 1 -d" "`)
			set goPID = "$goPID $pid"
		end
		echo "goPID $goPID"
		# Select signal to kill processes with - 0 is kill -15 (SIGTERM), 1 is kill -2 (SIGINT)
		set rand = `$ydb_dist/mumps -run rand 2`
		if ("0" == "$rand") then
			set killsig = "15"
		else
			set killsig = "2"
		endif
		kill -${killsig} $goPID
		# wait_for_proc_to_die.csh only works on one pid at a time
		foreach pid ($goPID)
			$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
		end
		if ("15" == $killsig) then
			# In case of SIGTERM/SIG-15, a FORCEDHALT message is expected to show up.
			# Filter that out so the error catching test framework does not see it.
			foreach file (${prog}${run}*.out)
				$gtm_tst/com/check_error_exist.csh $file "%YDB-F-FORCEDHALT" >&! ${file:r}.check.outx
			end
		endif
	end
	echo "done"
	$gtm_tst/com/dbcheck.csh >& dbcheck$prog.out || \
		echo "# dbcheck failed. Output of dbcheck$prog.out" && cat dbcheck$prog.out
end
