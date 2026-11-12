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
# Sourced by updhelper_statsdb-ydb1384.csh. $1 is the stage name. $2 is 1 if the helpers are expected to share
# statistics for region DEFAULT, else 0. $3 is 1 if the helper logs and the update process log are expected to report
# DBOPNERR for the statistics database (when statistics are shared but the statistics database cannot be created),
# else 0. Starts a passive source server and a receiver server with one reader and one writer helper, checks both
# helpers while they run, shuts the servers down, then checks the logs.

set stage = $1
set expshared = $2
set expdbopnerr = $3
echo '# Command : $MUPIP replicate -source -start -passive -instsecondary=INSTA -buffsize=1048576 \'
echo '#           -log=src_'$stage'.log'
$MUPIP replicate -source -start -passive -instsecondary=INSTA -buffsize=1048576 -log=src_$stage.log >&! srcstart_$stage.out
echo '# Command : $MUPIP replicate -receiver -start -listenport=<port> -buffsize=1048576 -helpers=2,1 \'
echo '#           -log=rcv_'$stage'.log'
$MUPIP replicate -receiver -start -listenport=$portno -buffsize=1048576 -helpers=2,1 -log=rcv_$stage.log >&! rcvstart_$stage.out
if ($status) then
	echo "FAIL : the receiver server did not start - see rcvstart_$stage.out"
	cat rcvstart_$stage.out
endif
# The helper log files are named after the pid of each helper. Wait for each helper to finish its startup, which
# ends either with the "started" line or with "Helper exiting".
set helperlogs = ""
foreach helper (reader writer)
	set kind = `echo $helper | cut -c1`
	set log = ""
	@ i = 0
	while ($i < 600)
		set log = `ls rcv_$stage.log.uh${kind}_* |& $grep -v "No match"`
		if ("$log" != "") then
			$grep -q -E "Helper $helper started|Helper exiting" $log
			if (0 == $status) break
		endif
		sleep 0.1
		@ i = $i + 1
	end
	if ("$log" == "") then
		echo "FAIL : no log file for the helper $helper after 60 seconds"
		continue
	endif
	set helperlogs = "$helperlogs ${helper}=$log"
	set pid = `echo $log:e | sed 's/^uh[rw]_//'`
	# A helper that fails in its startup logs "Helper exiting" and no "started" line. A Debug build can take a while
	# to dump its core and exit, so the "started" line is checked first.
	$grep -q "Helper $helper started" $log
	if ($status) then
		echo "FAIL : the helper $helper did not start. Its log follows."
		cat $log
	else
		# Give a helper that exits right after its startup time to do so
		sleep 1
		$gtm_tst/com/is_proc_alive.csh $pid
		if (0 == $status) then
			echo "PASS : the helper $helper started and is alive"
		else
			echo "FAIL : the helper $helper started but is not alive. Its log follows."
			cat $log
		endif
	endif
	set shared = `env gtm_statshare=1 $gtm_dist/mumps -run ygs^ydb1384 $pid`
	if ("$shared" == "$expshared") then
		if (1 == $expshared) then
			echo "PASS : the helper $helper shares statistics for region DEFAULT"
		else
			echo "PASS : the helper $helper does not share statistics for region DEFAULT"
		endif
	else
		echo "FAIL : ygs^ydb1384 returned [$shared] for the helper $helper, expected $expshared"
	endif
end
echo '# Command : $MUPIP replicate -receiver -shutdown -timeout=0'
$MUPIP replicate -receiver -shutdown -timeout=0 >&! rcvstop_$stage.out
echo '# Command : $MUPIP replicate -source -shutdown -timeout=0'
$MUPIP replicate -source -shutdown -timeout=0 >&! srcstop_$stage.out
# Check the complete logs of the helpers and of the update process
foreach entry ($helperlogs updproc=rcv_$stage.log.updproc)
	set who = `echo $entry | cut -d= -f1`
	set log = `echo $entry | cut -d= -f2`
	if ("updproc" == "$who") then
		set who = "the update process"
	else
		set who = "the helper $who"
	endif
	set others = `$grep -E -- "-[EFW]-" $log | $grep -v -E "DBOPNERR, Error opening database file .*\.gst|ENO13, Permission denied" | wc -l`
	if (0 != $others) then
		echo "FAIL : the log of $who has an unexpected error or warning - see $log"
		continue
	endif
	$grep -q "DBOPNERR" $log
	set seen = $status
	if (1 == $expdbopnerr) then
		if (0 == $seen) then
			echo "PASS : the log of $who has only DBOPNERR (ENO13), for the statistics database"
			$gtm_tst/com/check_error_exist.csh $log "DBOPNERR" "ENO13" >&! check_error_exist_${stage}_$log:e.logx
		else
			echo "FAIL : the log of $who does not report DBOPNERR for the statistics database"
		endif
	else
		if (0 == $seen) then
			echo "FAIL : the log of $who reports DBOPNERR - see $log"
		else
			echo "PASS : the log of $who has no error"
		endif
	endif
end
