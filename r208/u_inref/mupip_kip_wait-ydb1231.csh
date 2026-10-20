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

echo "#-----------------------------------------------------------------------------------------------#"
echo "# [#1231] MUPIP INTEG, FREEZE and BACKUP do not wait for an abandoned KILL                       #"
echo "#-----------------------------------------------------------------------------------------------#"
echo
echo "# A KILL whose process terminated without running its cleanup leaves kill_in_prog set in the file"
echo "# header, and its own process id in the shared memory list of processes doing a KILL, with nothing"
echo "# left that can clear either. MUPIP INTEG waited a minute for that field in ss_initiate, or in"
echo "# region_freeze_main for a -noonline INTEG, and then another minute in mu_int_maps, so MUKILLIP,"
echo "# which it was going to issue either way, took two minutes to arrive. MUPIP FREEZE and MUPIP BACKUP"
echo "# waited a minute before failing with MUNOFINISH and before warning with BACKUPKILLIP respectively."
echo "#"
echo "# The WBTEST_ABANDONEDKILL white box test case holds a process in phase II of a KILL, where"
echo "# kill_in_prog is set. This subtest terminates it there with SIGKILL, which the process cannot"
echo "# handle, so nothing of it runs again. Each stage times its command and compares the elapsed seconds"
echo "# against a limit instead of printing them, since the number itself is not reproducible."
echo "#"
echo "# The INTEG output goes to a file rather than to this log. Stopping a KILL in its second phase"
echo "# leaves blocks marked busy that nothing references any more, and INTEG reports one DBLOCMBINC"
echo "# and DBMRKBUSY per bitmap and block involved, which is not a fixed number across the block sizes"
echo "# the test system chooses from. MUKILLIP is asserted out of that file; the rest of it is gzipped"
echo "# so that com/errors.csh does not read those messages as a failure."
echo

# ONLINE INTEG, which this subtest runs explicitly, is not supported with the MM access method
source $gtm_tst/com/gtm_test_setbgaccess.csh
# WBTEST_ABANDONEDKILL holds a process in phase II of every KILL it does, not only the first. With statistics
# sharing on, a process also KILLs its own record in the statistics database when it exits, so each KILL of
# stage 6 would be held a second minute, and the wait for its process to exit could run out.
source $gtm_tst/com/unset_ydb_env_var.csh ydb_statshare gtm_statshare

$gtm_tst/com/dbcreate.csh mumps

# Each of the two waits is a minute, so an unfixed MUPIP INTEG takes just over 120 seconds at stages 1
# and 2, and a fixed one stops waiting within a second of noticing that the KILL has no process behind
# it. 30 seconds separates the two by a wide margin even on a loaded test system.
set limit = 30
# The seconds each of stages 1 to 5 took are appended to elapsed.log rather than printed, because they are
# not reproducible. They are there to look at when a stage comes close to the limit.

if ("pro" == "$tst_image") then
	echo "# Stages 1 to 6 need the WBTEST_ABANDONEDKILL white box test case, which is DEBUG only, so with a"
	echo "# pro build they are skipped and only stages 7 and 8 run"
	echo
else
	# A copy of the database as created, for stage 5 to put back
	$MUPIP rundown -region "*" >&! rundown1.out
	cp mumps.dat mumps_bak.dat

	echo '# Command : $gtm_dist/mumps -run setup^ydb1231'
	$gtm_dist/mumps -run setup^ydb1231
	echo "# Enable WBTEST_ABANDONEDKILL, which holds a process in phase II of every KILL it does"
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 21
	setenv gtm_white_box_test_case_count 1
	echo '# Command : $gtm_tst/$tst/u_inref/callabandon-ydb1231.csh, which starts [mumps -run abandon^ydb1231]'
	$gtm_tst/$tst/u_inref/callabandon-ydb1231.csh >&! callabandon.log
	$gtm_tst/com/wait_for_log.csh -log job.txt -waitcreation -duration 120
	set killpid = `cat job.txt`
	$gtm_tst/com/wait_for_log.csh -log abandon.outx -waitcreation -duration 60 -message "WBTEST_ABANDONEDKILL waiting in Phase II of Kill"
	echo "# Send SIGKILL to that process, whose pid it wrote to job.txt"
	kill -9 $killpid
	$gtm_tst/com/wait_for_proc_to_die.csh $killpid 60
	# The INTEGs below, and the final database check, must not run with the white box test case still
	# enabled. Unset the variable rather than setting it to 0: "wbox_test_init" turns white box testing on
	# when the variable EXISTS and never looks at its value, so a 0 leaves it on, and the next process
	# that reaches phase II of a KILL prints the WBTEST_ABANDONEDKILL message and sleeps for a minute.
	unsetenv gtm_white_box_test_case_enable
	unsetenv gtm_white_box_test_case_number
	unsetenv gtm_white_box_test_case_count

	echo '# Command : $DSE dump -fileheader, reporting the KILLs in progress field it shows'
	$DSE dump -fileheader >&! dse_dump1.out
	set kip = `$grep "KILLs in progress" dse_dump1.out | $tst_awk '{print $NF}'`
	if (0 != $kip) then
		echo "PASS : the file header reports a KILL in progress"
	else
		echo "FAIL : the file header reports no KILL in progress, expected one"
	endif
	echo

	echo "# Stage 1 : an ONLINE MUPIP INTEG, the default, which waited in ss_initiate and then in mu_int_maps"
	echo "# Expected : MUKILLIP within the 30 second limit, in under a second on an idle system"
	echo "# Before YDB#1231 : MUKILLIP after about 122 seconds, a minute in each of the two waits"
	echo '# Command : $MUPIP integ -reg "*" -online'
	set start = `date +%s`
	$MUPIP integ -reg "*" -online >&! integ_online.out
	set stop = `date +%s`
	@ elapsed = $stop - $start
	echo "Stage 1 : $elapsed seconds" >>&! elapsed.log
	$gtm_tst/com/check_error_exist.csh integ_online.out "YDB-W-MUKILLIP"
	$tst_gzip integ_online.out
	if ($elapsed < $limit) then
		echo "PASS : the ONLINE INTEG reported MUKILLIP in fewer than $limit seconds"
	else
		echo "FAIL : the ONLINE INTEG took $elapsed seconds, which is not fewer than $limit"
	endif
	echo

	echo "# Stage 2 : MUPIP INTEG -noonline, which waited in region_freeze_main and then in mu_int_maps"
	echo "# Expected : MUKILLIP within the 30 second limit, in under a second on an idle system"
	echo "# Before YDB#1231 : MUKILLIP after about 122 seconds, a minute in each of the two waits"
	echo '# Command : $MUPIP integ -reg "*" -noonline'
	set start = `date +%s`
	$MUPIP integ -reg "*" -noonline >&! integ_noonline.out
	set stop = `date +%s`
	@ elapsed = $stop - $start
	echo "Stage 2 : $elapsed seconds" >>&! elapsed.log
	$gtm_tst/com/check_error_exist.csh integ_noonline.out "YDB-W-MUKILLIP"
	$tst_gzip integ_noonline.out
	if ($elapsed < $limit) then
		echo "PASS : the -noonline INTEG reported MUKILLIP in fewer than $limit seconds"
	else
		echo "FAIL : the -noonline INTEG took $elapsed seconds, which is not fewer than $limit"
	endif
	echo

	echo "# Stage 3 : MUPIP FREEZE, which waited in region_freeze_main and then failed with MUNOFINISH"
	echo "# Expected : MUNOFINISH within the 30 second limit, in under a second on an idle system"
	echo "# Before YDB#1231 : MUNOFINISH after about 61 seconds"
	echo '# Command : $MUPIP freeze -on "*"'
	set start = `date +%s`
	$MUPIP freeze -on "*" >&! freeze.out
	set stop = `date +%s`
	@ elapsed = $stop - $start
	echo "Stage 3 : $elapsed seconds" >>&! elapsed.log
	$gtm_tst/com/check_error_exist.csh freeze.out "YDB-E-MUNOFINISH"
	$MUPIP freeze -off "*" >&! unfreeze.out
	if ($elapsed < $limit) then
		echo "PASS : the FREEZE failed with MUNOFINISH in fewer than $limit seconds"
	else
		echo "FAIL : the FREEZE took $elapsed seconds, which is not fewer than $limit"
	endif
	echo

	echo "# Stage 4 : MUPIP BACKUP -online, which waited in mupip_backup and then warned with BACKUPKILLIP"
	echo "# Expected : BACKUPKILLIP and BACKUPSUCCESS within the 30 second limit, in under a second on an"
	echo "# idle system"
	echo "# Before YDB#1231 : BACKUPKILLIP and BACKUPSUCCESS after about 61 seconds"
	echo '# Command : $MUPIP backup -online "*" bak'
	mkdir bak
	set start = `date +%s`
	$MUPIP backup -online "*" bak >&! backup.out
	set stop = `date +%s`
	@ elapsed = $stop - $start
	echo "Stage 4 : $elapsed seconds" >>&! elapsed.log
	$gtm_tst/com/check_error_exist.csh backup.out "YDB-W-BACKUPKILLIP"
	set success = `$grep -c "YDB-I-BACKUPSUCCESS" backup.out`
	if (($elapsed < $limit) && (1 == $success)) then
		echo "PASS : the BACKUP warned with BACKUPKILLIP and succeeded, in fewer than $limit seconds"
	else
		echo "FAIL : the BACKUP took $elapsed seconds and reported BACKUPSUCCESS $success times, expected"
		echo "       fewer than $limit seconds and 1"
	endif
	echo

	echo "# Stage 5 : put back the database as it was created, where no KILL was ever interrupted, and"
	echo "# check that an INTEG of it reports nothing and does not wait either"
	echo "# Expected : no errors and no MUKILLIP within the 30 second limit"
	echo "# Before YDB#1231 : the same, since there is no KILL in progress to wait for"
	echo '# Command : $MUPIP integ -reg "*" -online'
	$MUPIP rundown -region "*" >&! rundown2.out
	cp mumps_bak.dat mumps.dat
	set start = `date +%s`
	$MUPIP integ -reg "*" -online >&! integ_clean.out
	set stop = `date +%s`
	@ elapsed = $stop - $start
	echo "Stage 5 : $elapsed seconds" >>&! elapsed.log
	set mukillip = `$grep -c "MUKILLIP" integ_clean.out`
	set noerrors = `$grep -c "No errors detected by integ" integ_clean.out`
	if (($elapsed < $limit) && (0 == $mukillip) && (1 == $noerrors)) then
		echo "PASS : the INTEG detected no errors and reported no MUKILLIP, in fewer than $limit seconds"
	else
		echo "FAIL : the INTEG took $elapsed seconds, reported MUKILLIP $mukillip times and [No errors"
		echo "       detected by integ] $noerrors times, expected fewer than $limit seconds, 0 and 1"
	endif
	echo

	echo "# Stage 6 : a KILL in progress that the shared memory list of processes doing a KILL does not record."
	echo "# The list has 8 slots, so a ninth concurrent KILL is counted instead of recorded. Hold 8 KILLs in"
	echo "# phase II with WBTEST_ABANDONEDKILL, which sleeps there for about a minute, start a ninth 20 seconds"
	echo "# later, and let the first 8 finish. The ninth is still in phase II and alive, so an INTEG has to"
	echo "# wait for it rather than report MUKILLIP, and once it finishes the database has no errors."
	echo "# Expected : the INTEG waits for the ninth KILL, then reports no MUKILLIP and no errors"
	echo "# Before YDB#1231 : the same, since an INTEG then always waited for a KILL in progress"
	echo '# Command : $gtm_dist/mumps -run setupc^ydb1231'
	$gtm_dist/mumps -run setupc^ydb1231
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_number 21
	setenv gtm_white_box_test_case_count 1
	echo '# Command : $gtm_dist/mumps -run hold^ydb1231 <n>, in the background, for n = 1 to 8'
	foreach n (1 2 3 4 5 6 7 8)
		($gtm_dist/mumps -run hold^ydb1231 $n >&! hold$n.outx &)
	end
	foreach n (1 2 3 4 5 6 7 8)
		$gtm_tst/com/wait_for_log.csh -log hold$n.outx -waitcreation -duration 60 -message "WBTEST_ABANDONEDKILL waiting in Phase II of Kill"
	end
	sleep 20
	echo '# Command : $gtm_dist/mumps -run hold^ydb1231 9, in the background'
	($gtm_dist/mumps -run hold^ydb1231 9 >&! hold9.outx &)
	$gtm_tst/com/wait_for_log.csh -log hold9.outx -waitcreation -duration 60 -message "WBTEST_ABANDONEDKILL waiting in Phase II of Kill"
	unsetenv gtm_white_box_test_case_enable
	unsetenv gtm_white_box_test_case_number
	unsetenv gtm_white_box_test_case_count
	foreach n (1 2 3 4 5 6 7 8)
		$gtm_tst/com/wait_for_proc_to_die.csh `cat hold$n.pid` 120
	end
	set holdpid = `cat hold9.pid`
	$gtm_tst/com/is_proc_alive.csh $holdpid
	if ($status) then
		echo "FAIL : the ninth KILL finished before the first 8, so this stage tests nothing"
	else
		echo "PASS : the first 8 KILLs are done and the ninth is still in phase II"
	endif
	echo '# Command : $MUPIP integ -reg "*" -online'
	$MUPIP integ -reg "*" -online >&! integ_unrecorded.out
	set mukillip = `$grep -c "MUKILLIP" integ_unrecorded.out`
	set noerrors = `$grep -c "No errors detected by integ" integ_unrecorded.out`
	if ((0 == $mukillip) && (1 == $noerrors)) then
		echo "PASS : the INTEG waited for the ninth KILL, reported no MUKILLIP and detected no errors"
	else
		echo "FAIL : the INTEG reported MUKILLIP $mukillip times and [No errors detected by integ] $noerrors"
		echo "       times, expected 0 and 1"
		$tst_gzip integ_unrecorded.out
	endif
	$gtm_tst/com/wait_for_proc_to_die.csh $holdpid 120
	foreach n (1 2 3 4 5 6 7 8 9)
		$grep -q "kill done" hold$n.outx
		if ($status) echo "FAIL : hold^ydb1231 $n did not finish its KILL, see hold$n.outx"
	end
	echo
endif

echo "# Stage 7 : kip_set_by_dse in a database created by an older release. The field was taken from the"
echo "# end of secshr_ops_array_filler, so an older file header can carry any bytes there, and a non-zero"
echo "# value would make every wait act as if a DSE-set kill_in_prog were in progress. Auto upgrade has to"
echo "# zero it once, and only once, so that a kill_in_prog that DSE sets later is still recognised after"
echo "# DSE exits. This is done for a V7 database, which db_auto_upgrade handles, and for a V6 database,"
echo "# which v6_db_auto_upgrade handles. Each is created by a random prior release, gets 0xDEADBEEF"
echo "# written over the field, and is then opened by the current release."
set save_use_v6 = `printenv gtm_test_use_V6_DBs`
set save_gbldir = `printenv gtmgbldir`
setenv gtm_test_use_V6_DBs 0	# this stage picks the database format itself
echo "# Expected : kip_set_by_dse reads 0 after opening and is zeros on disk after close, then reads 1"
echo "# after DSE sets kill_in_prog and exits, and 0 after DSE clears it"
echo "# Before YDB#1231 : there is no kip_set_by_dse field, so offset^ydb1231 gets LVUNDEF and"
echo "# %PEEKBYNAME gets PBNINVALID"
echo '# Command : $gtm_dist/mumps -run offset^ydb1231'
set off = `$gtm_dist/mumps -run offset^ydb1231`
foreach type (V7 V6)
	echo "## Stage 7 with a $type database, in directory stage7_$type"
	mkdir stage7_$type
	cd stage7_$type
	$gtm_tst/com/random_ver.csh -type $type >&! prior_ver_$type.txt
	if (0 != $status) then
		echo "TEST-I-SKIP, No suitable prior $type version available, skipping this part of stage 7."
		cd ..
		continue
	endif
	set prior_ver = `cat prior_ver_$type.txt`
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	setenv gtmgbldir $type.gld
	echo "# Create $type.dat with a random prior release"
	$gtm_tst/com/dbcreate.csh $type >&! dbcreate_$type.out
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	echo '# Command : $GDE exit, which converts the global directory to the current format'
	$GDE exit >&! gde_$type.out
	echo "# Write 0xDEADBEEF over kip_set_by_dse in the file header of $type.dat"
	printf '\336\255\276\357' | dd of=$type.dat bs=1 seek=$off conv=notrunc >&! dd_$type.out
	set bytes = `od -An -tx1 -j $off -N4 $type.dat | tr -d ' '`
	if ("deadbeef" != "$bytes") echo "FAIL : the file header holds [$bytes] at kip_set_by_dse, expected [deadbeef]"
	echo '# Command : $gtm_dist/mumps -run peek^ydb1231, which opens the database and reads kip_set_by_dse'
	set value = `$gtm_dist/mumps -run peek^ydb1231`
	if ("0" == "$value") then
		echo "PASS : the current release reads kip_set_by_dse as 0"
	else
		echo "FAIL : the current release reads kip_set_by_dse as [$value], expected 0"
	endif
	set bytes = `od -An -tx1 -j $off -N4 $type.dat | tr -d ' '`
	if ("00000000" == "$bytes") then
		echo "PASS : the file header holds zeros at kip_set_by_dse after the database is closed"
	else
		echo "FAIL : the file header holds [$bytes] at kip_set_by_dse after the database is closed, expected [00000000]"
	endif
	echo '# Command : $DSE change -fileheader -kill_in_prog=1'
	$DSE change -fileheader -kill_in_prog=1 >&! dse_set_$type.out
	set value = `$gtm_dist/mumps -run peek^ydb1231`
	if ("1" == "$value") then
		echo "PASS : kip_set_by_dse is 1 after DSE exits, so auto upgrade did not zero it a second time"
	else
		echo "FAIL : kip_set_by_dse is [$value] after DSE exits, expected 1"
	endif
	echo '# Command : $DSE change -fileheader -kill_in_prog=0'
	$DSE change -fileheader -kill_in_prog=0 >&! dse_clear_$type.out
	set value = `$gtm_dist/mumps -run peek^ydb1231`
	if ("0" == "$value") then
		echo "PASS : kip_set_by_dse is 0 again"
	else
		echo "FAIL : kip_set_by_dse is [$value] after DSE clears kill_in_prog, expected 0"
	endif
	$gtm_tst/com/dbcheck.csh >&! dbcheck_$type.out
	$grep -q "No errors detected by integ" dbcheck_$type.out
	if ($status) echo "FAIL : the INTEG of $type.dat reported errors, see stage7_$type/dbcheck_$type.out"
	cd ..
end
setenv gtmgbldir $save_gbldir
if ("" == "$save_use_v6") then
	unsetenv gtm_test_use_V6_DBs
else
	setenv gtm_test_use_V6_DBs $save_use_v6
endif
echo

echo "# Stage 8 : DSE MAPS -RESTORE, which an operator runs to repair the bitmaps an abandoned KILL leaves,"
echo "# clears kill_in_prog, so it has to clear kip_set_by_dse as well. Otherwise a later abandoned KILL"
echo "# would be taken for one that DSE set, and every wait for it would run its full minute again."
echo "# Expected : kip_set_by_dse is 1 after the DSE set, and kip_set_by_dse and kill_in_prog are both 0"
echo "# after DSE MAPS -RESTORE"
echo "# Before YDB#1231 : there is no kip_set_by_dse field, so %PEEKBYNAME gets PBNINVALID"
echo '# Command : $DSE change -fileheader -kill_in_prog=1'
$DSE change -fileheader -kill_in_prog=1 >&! dse_set_maps.out
set value = `$gtm_dist/mumps -run peek^ydb1231`
if ("1" == "$value") then
	echo "PASS : kip_set_by_dse is 1"
else
	echo "FAIL : kip_set_by_dse is [$value] after DSE sets kill_in_prog, expected 1"
endif
echo '# Command : $DSE maps -restore'
$DSE maps -restore >&! dse_maps_restore.out
set value = `$gtm_dist/mumps -run peek^ydb1231`
$DSE dump -fileheader >&! dse_dump2.out
set kip = `$grep "KILLs in progress" dse_dump2.out | $tst_awk '{print $NF}'`
if (("0" == "$value") && ("0" == "$kip")) then
	echo "PASS : kip_set_by_dse and kill_in_prog are both 0"
else
	echo "FAIL : kip_set_by_dse is [$value] and kill_in_prog is [$kip] after DSE MAPS -RESTORE, expected 0 and 0"
endif
echo

echo "# Done"
$gtm_tst/com/dbcheck.csh
