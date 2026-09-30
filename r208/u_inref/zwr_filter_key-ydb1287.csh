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
# Helper for load_zwr_cut_key-ydb1287 : replicate INSTA to INSTB through a filter that rewrites the key of a SET of
# ^zebad into the $ze(...) form. $1 is "source" to run the filter in the source server of INSTA, or "receiver" to run
# it in the receiver server of INSTB. It runs as a separate process so the ydb_gbldir and ydb_repl_instance it sets
# for each instance do not leak back into the subtest.
#

set side = "$1"
set dir = `pwd`
source $gtm_tst/com/portno_acquire.csh >>& portno.out
set filter = \""$gtm_exe/mumps -run filter^ydb1287"\"
set srcfilter = ""
set rcvfilter = ""
if ("source" == "$side") then
	set srcfilter = "-filter=$filter"
else
	set rcvfilter = "-filter=$filter"
endif
set A = ${side}A
set B = ${side}B

echo "# Create instances INSTA (in $A) and INSTB (in $B), each with one region, journaled and replicated"
foreach inst (A B)
	set idir = $side$inst
	mkdir $idir
	setenv ydb_gbldir $dir/$idir/mumps.gld
	setenv ydb_repl_instance $dir/$idir/mumps.repl
	$gtm_exe/mumps -run GDE >& $idir/gde.out << GDE_EOF
change -segment DEFAULT -file_name=$dir/$idir/mumps.dat
exit
GDE_EOF
	$MUPIP create >& $idir/create.out
	# As dbcreate.csh does: the test system sets gtm_db_counter_sem_incr only for QDBRUNDOWN databases, and without
	# QDBRUNDOWN the processes attached to the database overflow its counter semaphore (CRITSEMFAIL)
	if ("1" == "`printenv gtm_test_qdbrundown`") then
		$MUPIP set -qdbrundown -region DEFAULT >& $idir/set_qdbrundown.out
	endif
	$MUPIP set -journal="enable,on,nobefore" -replication=on -region DEFAULT >& $idir/set_replic.out
	$MUPIP replicate -instance_create -name=INST$inst $gtm_test_qdbrundown_parms >& $idir/instance_create.out
end

setenv ydb_gbldir $dir/$B/mumps.gld
setenv ydb_repl_instance $dir/$B/mumps.repl
if ("receiver" == "$side") then
	echo '# Start a passive source server, and a receiver server with -filter="$gtm_exe/mumps -run filter^ydb1287", for INSTB'
else
	echo '# Start a passive source server and a receiver server for INSTB'
endif
$MUPIP replicate -source -start -passive -instsecondary=INSTA -buffsize=1048576 -log=$dir/$B/passive_source.log >& $B/passive_source_start.out
$MUPIP replicate -receiver -start -listenport=$portno -buffsize=1048576 -log=$dir/$B/receiver.log $rcvfilter >& $B/receiver_start.out
set rcvpid = `$MUPIP replicate -receiver -checkhealth |& $tst_awk '/Receiver server is alive/ {print $2; exit}'`

setenv ydb_gbldir $dir/$A/mumps.gld
setenv ydb_repl_instance $dir/$A/mumps.repl
if ("source" == "$side") then
	echo '# Start the source server for INSTA with -filter="$gtm_exe/mumps -run filter^ydb1287"'
else
	echo '# Start the source server for INSTA'
endif
$MUPIP replicate -source -start -secondary=localhost:$portno -instsecondary=INSTB -buffsize=1048576 -log=$dir/$A/source.log $srcfilter >& $A/source_start.out
set srcpid = `$MUPIP replicate -source -checkhealth |& $tst_awk '/Source server is alive/ {print $2; exit}'`
$gtm_tst/com/wait_for_log.csh -log $A/source.log -message "New History Content" -duration 300

echo '# Run [set ^good=1,^zebad="abc",^after=2] on INSTA. The filter returns the SET of ^zebad as a SET of $ze(^zebad,0,3)'
$gtm_exe/mumps -run %XCMD 'set ^good=1,^zebad="abc",^after=2'

if ("source" == "$side") then
	set pid = $srcpid
	set log = $A/source.log
else
	set pid = $rcvpid
	set log = $B/receiver.log
endif
echo "# expect the $side server to exit, reporting NOTGBL for the "'$ze(...)'" key, and not to be killed by a signal"
$gtm_tst/com/wait_for_proc_to_die.csh $pid 300
if ($status) then
	echo "WRONG : the $side server is still alive"
else
	echo "PASS : the $side server exited"
endif
$grep -q KILLBYSIG $log
if ($status) then
	echo "PASS : the $side server was not killed by a signal"
else
	echo "WRONG : the $side server was killed by a signal :"
	$grep -E -A 1 KILLBYSIG $log
endif
$gtm_tst/com/check_error_exist.csh $log NOTGBL

echo '# expect INSTB to hold ^good, sent before the rewritten SET, and neither ^zebad nor ^after, as nothing after it is applied'
setenv ydb_gbldir $dir/$B/mumps.gld
setenv ydb_repl_instance $dir/$B/mumps.repl
$gtm_exe/mumps -run replcheck^ydb1287

echo "# Shut down the replication servers still running, and run down the instance whose $side server exited"
if ("source" == "$side") then
	$MUPIP replicate -receiver -shutdown -timeout=0 >& $B/receiver_shutdown.out
	$MUPIP replicate -source -shutdown -timeout=0 >& $B/passive_source_shutdown.out
	setenv ydb_gbldir $dir/$A/mumps.gld
	setenv ydb_repl_instance $dir/$A/mumps.repl
	$MUPIP rundown -region "*" -override >& $A/rundown.out
else
	# The update process outlives the receiver server, so shut it down too
	$MUPIP replicate -receiver -shutdown -timeout=0 >& $B/receiver_shutdown.out
	$MUPIP replicate -source -shutdown -timeout=0 >& $B/passive_source_shutdown.out
	$MUPIP rundown -region "*" -override >& $B/rundown.out
	setenv ydb_gbldir $dir/$A/mumps.gld
	setenv ydb_repl_instance $dir/$A/mumps.repl
	$MUPIP replicate -source -shutdown -timeout=0 >& $A/source_shutdown.out
endif
# As dbcheck.csh does: with QDBRUNDOWN and gtm_db_counter_sem_incr, even a clean shutdown can leave shared memory behind
foreach inst (A B)
	setenv ydb_gbldir $dir/$side$inst/mumps.gld
	setenv ydb_repl_instance $dir/$side$inst/mumps.repl
	tcsh -f $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0
end
$gtm_tst/com/portno_release.csh
