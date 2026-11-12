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
echo "# [YDB#1384] Update helper processes exit when the statistics database of a region cannot be         #"
echo "# created or opened                                                                                  #"
echo "#----------------------------------------------------------------------------------------------------#"
echo
echo '# At startup, the update helper processes opened every region of the global directory with'
echo '# gvcst_init(), including the statistics database regions. When statistics were not shared and a'
echo '# statistics database could not be created or opened, for example because the directory that'
echo '# gtm_statsdir names is not writable, that was an error and the helper exited. A Release build'
echo '# reported DBOPNERR, and a Debug build also failed an assert in gvcst_init.c and dumped a core. Other'
echo '# processes open a statistics database only when statistics are shared, through gvcst_init_statsDB(),'
echo '# which turns off statistics for the region if the open fails.'
echo '#'
echo '# Each stage starts a passive source server and a receiver server with one reader and one writer'
echo '# helper, and checks that both helpers are alive, whether they share statistics for region DEFAULT'
echo '# (ygs^ydb1384 checks ^%YGS for the pid of the helper), and the logs of the helpers and of the update'
echo '# process.'
echo

setenv gtm_test_spanreg 0
setenv gtm_test_jnl NON_SETJNL
unsetenv gtm_db_counter_sem_incr	# the instance file is created without -qdbrundown
setenv gtm_repl_instance mumps.repl
# Each stage sets the statistics environment itself
unsetenv gtm_statshare ydb_statshare gtm_statsdir ydb_statsdir

# MUPIP SET -REPLICATION=ON below enables before-image journaling, which needs the BG access method
source $gtm_tst/com/gtm_test_setbeforeimage.csh
$gtm_tst/com/dbcreate.csh mumps >&! dbcreate.out
if ($status) then
	echo "# dbcreate.csh failed. Output follows."
	cat dbcreate.out
endif
source $gtm_tst/com/portno_acquire.csh >>& portno.out
cp $gtm_tst/$tst/inref/ydb1384.m .
mkdir statsdir_ro statsdir_rw

echo '# Stage 1 : make this instance a secondary'
echo '# Command : $MUPIP replicate -instance_create -name=INSTB'
$MUPIP replicate -instance_create -name=INSTB >&! instcreate.out
set stat1 = $status
echo '# Command : $MUPIP set -replication=on -region DEFAULT'
$MUPIP set -replication=on -region DEFAULT >&! setrepl.out
set stat2 = $status
if ((0 == $stat1) && (0 == $stat2)) then
	echo "PASS : the instance file was created and replication is on"
else
	echo "FAIL : the replication setup failed - see instcreate.out and setrepl.out"
	cat instcreate.out setrepl.out
endif
echo

echo '# Stage 2 : gtm_statsdir names a directory that is not writable, and gtm_statshare is not set'
echo '# Commands: chmod 555 statsdir_ro'
echo '#           setenv gtm_statsdir $PWD/statsdir_ro'
echo '# Before the fix : both helpers exited at startup, after DBOPNERR in their logs (and an assert failure'
echo '#                  and a core in a Debug build)'
echo '# With the fix   : expect both helpers to start and stay alive, without statistics'
chmod 555 statsdir_ro
setenv gtm_statsdir $PWD/statsdir_ro
source $gtm_tst/$tst/u_inref/updhelper_statsdb_stage-ydb1384.csh stage2 0 0
echo

echo '# Stage 3 : gtm_statsdir names a directory that is not writable, and gtm_statshare is set (this stage'
echo '#           is a control)'
echo '# Command : setenv gtm_statshare 1'
echo '# Before the fix : both helpers started and stayed alive, without statistics, with DBOPNERR in the'
echo '#                  logs of the helpers and of the update process. When statistics are shared, the open'
echo '#                  of region DEFAULT tries to open the statistics database first and turns off'
echo '#                  statistics for the region when that fails, so the helpers did not open the'
echo '#                  statistics database region later.'
echo '# With the fix   : expect both helpers to start and stay alive, without statistics, as the statistics'
echo '#                  database cannot be created. The logs of the helpers and of the update process'
echo '#                  report DBOPNERR for the statistics database.'
setenv gtm_statshare 1
source $gtm_tst/$tst/u_inref/updhelper_statsdb_stage-ydb1384.csh stage3 0 1
echo

echo '# Stage 4 : gtm_statsdir names a writable directory, and gtm_statshare is set (this stage is a'
echo '#           control)'
echo '# Command : setenv gtm_statsdir $PWD/statsdir_rw'
echo '# Before the fix : both helpers started and stayed alive, sharing statistics'
echo '# With the fix   : expect both helpers to start and stay alive, sharing statistics'
setenv gtm_statsdir $PWD/statsdir_rw
source $gtm_tst/$tst/u_inref/updhelper_statsdb_stage-ydb1384.csh stage4 1 0
echo

chmod 755 statsdir_ro
unsetenv gtm_statshare gtm_statsdir
$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh >&! dbcheck.out
if ($status) then
	echo "# dbcheck.csh failed. Output follows."
	cat dbcheck.out
endif

echo "# Done"
