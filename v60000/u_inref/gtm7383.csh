#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Automation Plan :
# Run updates with a)before image journaling and b)nobefore image journaling for 1) 5 seconds and 2) 60 seconds.
# strace/truss the above routine doing the updates and note down the number of fsyncs (for db and jnl) and msyncs (for db).
# The expectations are:
# * db fsyncs should be higher for long running updates with before image journaling
# * jnl fsyncs should be higher for long running updates (irrespective of before/nobefore and MM/BG)
# * db fsyncs should be exactly (1) for BG and nobefore image journaling (invoked during shutdown)
# * db msyncs should be exactly (1) for MM and nobefore image journaling (invoked during shutdown)

# We are only going to use the fsync numbers and not pwrite numbers. pwrite calls are actually higher in the nobefore case even
# though we avoid writes to the db during the epoch. This is because the nobefore case does a lot more updates in the same
# timeframe and due to the buffer cache not fitting the entire database, we need to keep flushing blocks even in the nobefore image
# case in order to be able to read/modify new blocks.

set save_acc_meth = $acc_meth
set fsync = "fsync"
set msync_pattern = "msync(.*= "
if ("sunos" == "$gtm_test_osname") then
	set fsync = "fdsync"
	set msync_pattern = "memcntl(.*MS_SYNC.*= "
endif
foreach b4nob4 ("before" "nobefore")
	foreach runtime (5 60)
		# create db with sufficiently large allocation, to avoid extension which will do fsync and disturb the count we do
		# in the test
		if ("nobefore" == $b4nob4) then
			setenv acc_meth "$save_acc_meth"
		else
			setenv acc_meth "BG"
		endif
		set trussfile = "truss_${b4nob4}_${runtime}.outx"
		$gtm_tst/com/dbcreate.csh mumps 1 1000 4096 10000 40960 >&! dbcreate_${b4nob4}_${runtime}.out
		setenv gtm_time $runtime
		echo "# Running updates for $runtime seconds with $b4nob4 journaling on"
		$MUPIP set -journal="enable,on,$b4nob4,epoch=1" -reg "*" >>&! set_jnl.out
		$truss $gtm_exe/mumps -run gtm7383 >& $trussfile
		set dbfd = `$grep 'open.*mumps.dat"' $trussfile		\
				| $gtm_exe/mumps -run XCMDLOOP --xec=@'write $piece($piece(%l,"=",$length(%l,"="))," ",2),!'@`
		set jnlfd = `$grep 'open.*mumps.mjl"' $trussfile		\
				| $gtm_exe/mumps -run XCMDLOOP --xec=@'write $piece($piece(%l,"=",$length(%l,"="))," ",2),!'@`
		set dbfsync_${b4nob4}_${runtime} = `$grep -c "${fsync}($dbfd.*= " $trussfile`
		set dbmsync_${b4nob4}_${runtime} = `$grep -c "$msync_pattern" $trussfile`
		set jnlfsync_${runtime} = `$grep -c "${fsync}($jnlfd.*= " $trussfile`
		$gtm_tst/com/dbcheck.csh >&! dbcheck_${b4nob4}_${runtime}.out
		$gtm_tst/com/backup_dbjnl.csh bak_${b4nob4}_${runtime}
	end
end



if ("MM" == $save_acc_meth) then
	if ("aix" != $gtm_test_osname) then
		echo "# Check that ONLY 1 DB msync happened in case of nobefore image journaling irrespective of the duration of updates"
		if (($dbmsync_nobefore_5 == $dbmsync_nobefore_60) && ($dbmsync_nobefore_5 == 1)) then
			echo "TEST-I-PASS. ONLY 1 DB msync seen"
		else
			echo "TEST-E-FAIL. DB msyncs in 5 second duration = $dbmsync_nobefore_5 & 60 second duration = $dbmsync_nobefore_60"
		endif
	endif
else
	echo "# Check that ONLY 1 DB fsync happened in case of nobefore image journaling irrespective of the duration of updates"
	if (($dbfsync_nobefore_5 == $dbfsync_nobefore_60) && ($dbfsync_nobefore_5 == 1))then
		echo "TEST-I-PASS. ONLY 1 DB fsync seen"
	else
		echo "TEST-E-FAIL. DB fsyncs in 5 second duration = $dbfsync_nobefore_5 & 60 second duration = $dbfsync_nobefore_60"
	endif
endif

echo "# Check that # of JNL fsyncs increase with the number of updates and duration irrespective of MM or BG and NOBEFORE/BEFORE"
if ($jnlfsync_5 < $jnlfsync_60) then
	echo "TEST-I-PASS. # of JNL fsyncs for 60 second duration is greater than # JNL fsyncs for 5 second duration"
else
	echo "TEST-E-FAIL. # of JNL fsyncs in 5 second duration = $jnlfsync_5 & 60 second duration = $jnlfsync_60"
endif
# With VMs we have seen fsync delays. A test failure showed fsyncs taking as much as 20 seconds and due to this delay the number
# of fsyncs for a 60 second run is not 3x times the number of fsyncs of a 5sec run. An ideal fix would be the below if the 3x
# check fails, find out how long each fsync took and for each second that it spanned count one more fsync than actually happened.
# So if an fsync took 12 seconds to complete, treat that as 12 fsyncs. This is reasonable as we have epoch interval set to 1 and
# so expect an fsync every 1 sec. With this calculation, we will easily reach the 3x calculation. Since this is not real quick to
# implement, we have reduced the expectation from 3x to 2x for now for the before-image case of 5sec vs 60sec and keep the
# fsync-per-second suggestion for later if such a failure happens again even with 2x. (and then increase # it back to 3x)
echo "# Checking if the # of DB fsyncs in case of before image journaling increases significantly with the duration of updates"
@ dbfsync_before_5_3X = 2 * $dbfsync_before_5
if ($dbfsync_before_60 > $dbfsync_before_5_3X) then
	echo "TEST-I-PASS. The # of DB fsyncs in a before image case increased significantly between 5 sec update and 60 sec update"
else
	echo "TEST-E-FAIL. The # of DB fsyncs in a before image case is expected to increase at least 2x times between a 5 sec update and 60sec update"
	echo "But they were $fsync_before_5 for 5 seconds update and $fsync_before_60 for 60 seconds update"
endif
