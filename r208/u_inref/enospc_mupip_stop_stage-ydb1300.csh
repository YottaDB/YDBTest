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
#
# One stage of r208/enospc_mupip_stop-ydb1300. $1 is the stage name:
#   dbtp    : a database write by the flush timer at the end of a TP commit gets a (fake) ENOSPC
#   jnltp   : the same, with the ENOSPC on the journal file write
#   blocked : as dbtp, and the instance freeze is then changed by another process (the DSKNOSPCBLOCKED case)
#   crit    : a database write done while holding crit in phase 1 of a TP commit gets a (fake) ENOSPC
#
# Process A runs under gdb, which turns on fake ENOSPC in the database shared memory at the chosen point.
# A then waits in wait_for_disk_space() with the instance frozen and is stopped with MUPIP STOP.
# Process B then updates the same globals.

set stage = $1
set flag = fake_db_enospc
if ("jnltp" == "$stage") set flag = fake_jnl_enospc

$gtm_dist/mupip replicate -source -freeze >& freeze_before_$stage.logx
$grep -q "Freeze: OFF" freeze_before_$stage.logx
if (! $status) then
	echo "# The instance is not frozen before the stage : as expected"
else
	echo "# The instance is not frozen before the stage : WRONG, see freeze_before_$stage.logx"
endif

# The gdb breakpoints below are on function names, not source lines, so that the test does not depend on line numbers.
if ("crit" == "$stage") then
	# Stop in bg_update_phase1() (which runs while holding crit) during the TP commit, at a point where some buffers
	# are waiting to be written, and flush them from there with wcs_wtstart() as wcs_get_space() would. That call does
	# not return: the process is stopped while it waits for disk space. gdb stays attached, so let it pass SIGTERM
	# (MUPIP STOP) and SIGALRM (timers) through to the process.
	cat > gdb_a_$stage.cmd << CAT_EOF
set breakpoint pending on
set confirm off
set pagination off
handle SIGALRM nostop noprint pass
handle SIGTERM nostop noprint pass
break bg_update_phase1 if \$_caller_is("tp_tend") && (cs_addrs->nl->wcs_active_lvl > 0)
run
delete
set var cs_addrs->nl->$flag = 1
printf "YDB1300-A: stopped in bg_update_phase1() during tp_tend(), holding crit : %d\n", cs_addrs->now_crit
call (int)wcs_wtstart(gv_cur_region, 0, 0, 0)
quit
CAT_EOF
	set mlabel = crit
else
	# Stop in rel_crit() at the end of the second TP commit (the first one started the flush timer) and sleep 2
	# seconds so the flush timer is due. Its handling is deferred until the end of tp_tend(), and the flush then
	# gets the fake ENOSPC while the commit still counts as underway. Detach once A waits for disk space.
	# The fake ENOSPC is turned on for the region that rel_crit() was called for, as cs_addrs can point to another
	# region (e.g. a statsdb region).
	set freezecmd = "echo"
	if ("blocked" == "$stage") set freezecmd = "shell $gtm_dist/mupip replicate -source -freeze=on -comment=ydb1300"
	cat > gdb_a_$stage.cmd << CAT_EOF
set breakpoint pending on
set confirm off
set pagination off
break rel_crit if \$_caller_is("tp_tend")
ignore 1 1
run
shell sleep 2
delete
set var ((unix_db_info *)reg->dyn.addr->file_cntl->file_info)->s_addrs.nl->$flag = 1
break wait_for_disk_space
continue
delete
printf "YDB1300-A: in wait_for_disk_space() during tp_tend() : %d\n", \$_any_caller_is("tp_tend", 30)
$freezecmd
detach
quit
CAT_EOF
	set mlabel = tp
endif

if ("crit" == "$stage") then
	echo "# Command : gdb -x gdb_a_$stage.cmd --args mumps -run crit^ydb1300 $stage   (process A, in the background)"
	echo "#   gdb turns on $flag when A is in phase 1 of a TP commit holding crit, and calls wcs_wtstart() there"
else if ("blocked" == "$stage") then
	echo "# Command : gdb -x gdb_a_$stage.cmd --args mumps -run tp^ydb1300 $stage   (process A, in the background)"
	echo "#   gdb turns on $flag at the end of the second TP commit, and once A waits for disk space runs"
	echo "#   mupip replicate -source -freeze=on -comment=ydb1300"
else
	echo "# Command : gdb -x gdb_a_$stage.cmd --args mumps -run tp^ydb1300 $stage   (process A, in the background)"
	echo "#   gdb turns on $flag at the end of the second TP commit"
endif
# Start of the syslog window searched below (local time, as com/getoper.csh expects)
set syslog_start = `date +"%b %e %H:%M:%S"`
# Create the gdb output file before gdb starts so the wait loop below never greps a file that does not exist yet
touch gdb_a_$stage.out
# Start gdb in the background from sh, which also records its pid (a tcsh background job prints job notices)
sh -c 'gdb -batch -x gdb_a_'$stage'.cmd --args '$gtm_dist'/mumps -run '${mlabel}'^ydb1300 '$stage' > gdb_a_'$stage'.out 2>&1 & echo $! > gdb_a_'$stage'.pid'
set gdbpid = `cat gdb_a_$stage.pid`

# Wait (at most 120 seconds) for gdb to report where A is
set i = 0
while ($i < 240)
	$grep -q "^YDB1300-A:" gdb_a_$stage.out
	if (! $status) break
	sleep 0.5
	@ i = $i + 1
end
set where = `$grep "^YDB1300-A:" gdb_a_$stage.out`
if ("crit" == "$stage") then
	set expect = "YDB1300-A: stopped in bg_update_phase1() during tp_tend(), holding crit : 1"
else
	set expect = "YDB1300-A: in wait_for_disk_space() during tp_tend() : 1"
endif
if ("$where" == "$expect") then
	echo "# $where : as expected"
else
	echo "# gdb reported [$where] : WRONG, expected [$expect]"
endif

# Wait (at most 120 seconds) for A to freeze the instance from wait_for_disk_space()
set i = 0
set frozen = 0
while ($i < 240)
	$gtm_dist/mupip replicate -source -freeze >& freeze_$stage.logx
	$grep -q "Freeze: ON" freeze_$stage.logx
	if (! $status) then
		set frozen = 1
		break
	endif
	sleep 0.5
	@ i = $i + 1
end
if ($frozen) then
	echo "# The instance is frozen : as expected"
else
	echo "# The instance is frozen : WRONG, it did not freeze within 120 seconds"
endif
set apid = 0
if (-e $stage.pid) then
	set apid = `cat $stage.pid`
else
	echo "# Process A wrote its pid : WRONG, $stage.pid does not exist"
endif
if ("blocked" == "$stage") then
	# wait_for_disk_space() sends DSKNOSPCBLOCKED just before it waits for the freeze to be lifted, and A can leave that
	# wait only when the freeze is lifted or an exit request arrives. The freeze stays on until after the MUPIP STOP below,
	# so a DSKNOSPCBLOCKED message from A shows that A is in that wait when it is stopped. Wait (at most 120 seconds) for it.
	# com/getoper.csh is called without a message, so it waits only for a marker that it writes to syslog itself.
	set i = 0
	set blocked = 0
	while ($i < 60)
		$gtm_tst/com/getoper.csh "$syslog_start" "" syslog_$stage.txt >& getoper_$stage.logx
		$grep -q "\[$apid\]: %YDB-E-DSKNOSPCBLOCKED" syslog_$stage.txt
		if (! $status) then
			set blocked = 1
			break
		endif
		sleep 2
		@ i = $i + 1
	end
	if ($blocked) then
		echo "# Process A reported DSKNOSPCBLOCKED : as expected"
	else
		echo "# Process A reported DSKNOSPCBLOCKED : WRONG, no DSKNOSPCBLOCKED message from process A in syslog within 120 seconds"
	endif
endif

echo "# Command : mupip stop <pid of process A>"
# Never pass a pid of 0 (or anything that is not a positive number): MUPIP STOP 0 would signal the whole process group
if ("$apid" =~ [1-9]*) then
	$gtm_dist/mupip stop $apid >& mupip_stop_$stage.out
	$gtm_tst/com/wait_for_proc_to_die.csh $apid 120 . nolog 1 >& wait_for_proc_to_die_$stage.out
	if (! $status) then
		echo "# Process A terminated : as expected"
	else
		echo "# Process A terminated : WRONG, it is still alive after 120 seconds"
	endif
else
	echo "# Process A terminated : WRONG, no pid of process A to stop"
endif
# gdb ends once A has terminated (it has already detached, except in the crit stage)
$gtm_tst/com/wait_for_proc_to_die.csh $gdbpid 120 . nolog 1 >& wait_for_gdb_to_die_$stage.out
if ($status) then
	echo "# gdb for process A ended : WRONG, it is still alive after 120 seconds"
endif

$grep -q "ASSERT" gdb_a_$stage.out
if ($status) then
	echo "# Process A had no assert failure : as expected"
else
	echo "# Process A had no assert failure : WRONG, see gdb_a_$stage.out"
endif
$gtm_tst/com/check_error_exist.csh gdb_a_$stage.out FORCEDHALT

echo "# Command : mupip replicate -source -freeze=off"
$gtm_dist/mupip replicate -source -freeze=off >& unfreeze_$stage.out

echo "# Command : gdb -x gdb_b.cmd --args mumps -run b^ydb1300   (process B, turns $flag off again in t_end())"
timeout 120 gdb -batch -x gdb_b.cmd --args $gtm_dist/mumps -run b^ydb1300 >& gdb_b_$stage.out
set bstatus = $status
$grep -q "^B updated" gdb_b_$stage.out
if ((! $status) && (0 == $bstatus)) then
	echo "# Process B updated ^x, ^y and ^z(1) and exited : as expected"
else
	echo "# Process B updated ^x, ^y and ^z(1) and exited : WRONG, exit status $bstatus, see gdb_b_$stage.out"
endif
echo
