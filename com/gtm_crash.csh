#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Kill all GTM processes
#
if ($1 == "") echo "Simulating kill of GTM Processes in `pwd`"
# if the first argument is PID_ then treat all other arguments as PID's and crash them
# it is the calling programs job to pass the correct PID's
if ($1 == "PID_") then
	echo -n "Simulating kill of GTM/YDB Processes with PID "
	set pids=""
	# set the PID's list
	foreach i (`seq 2 1 $#`)
		set pids="$pids $argv[$i]"
	end
	echo $pids
else
	set pids=`$tst_awk '$1 ~ /PID/ {print $2}' *${gtm_test_jobid}.mjo*`
	# "pids" contains the list of imptp processes that were jobbed off.
endif
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG pkill_${kill_time}.logx

echo "Before Kill >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi|yottadb" >>& $KILL_LOG

# PID for mumps
set pidcheck = "${pids:as/ /|/}"

# IPCS
set db_ftok_key = `$MUPIP ftok -id=43 *.dat |& $tst_awk '/dat/{print substr($10, 2, 10);}'`
setenv ftok_key "$db_ftok_key"
if ($1 == "NO_SHM_REM") then
	set dbipc_private = ""
	foreach file (*.dat)
		set ipc = `$MUPIP ftok $file |& $tst_awk '/dat/{printf("-s %s",$3);}'`
		set dbipc_private = "$dbipc_private $ipc"
	end
else
	set dbipc_private = `$gtm_tst/com/db_ftok.csh`
endif

#################################
date >>& $KILL_LOG
echo "$kill9 $pids" >>& $KILL_LOG
echo "$gtm_tst/com/ipcrm <ipc_private> $dbipc_private" >>& $KILL_LOG
echo "ipcrm <ftok_key> $ftok_key" >>& $KILL_LOG
echo "MUPIP rundown -relinkctl" >>& $KILL_LOG
#################################
$kill9 $pids
#################################
date >>& $KILL_LOG
#
$gtm_tst/com/ipcrm $dbipc_private >>& $KILL_LOG
$gtm_tst/com/rem_ftok_sem.csh $ftok_key # arguments $ftok_key
# Collecting the IDs of relinkctl shared memory segments from the RCTLDUMP is prohibitive, so clean directly.
$MUPIP rundown -relinkctl >>& $KILL_LOG

# Now that any ipcs that were recorded in the db file header have been cleaned, check semaphores of MM gtmhelp.dat files
# that were potentially open (these are not recorded in any db file header and have to be examined using "ipcs -s") and
# clean them up as otherwise they would be orphaned and accumulate in the system.
$gtm_tst/com/imptp_crash_helpdb_semclean.csh $KILL_LOG "$pids"

#################################
#
# Automatic unfreeze does not take place in two cases: 1) The passive source server is killed after setting fake ENOSPC flag.
# 2) mumps process is killed after setting the freeze (the process which set the freeze is responsible for unsetting it as well).
if ($?test_replic && $?gtm_test_fake_enospc) then
	if (1 == $gtm_test_fake_enospc) then
		echo "# Unfreezing. REPLREQROLLBACK error may occur." >>& $KILL_LOG
		$MUPIP replicate -source -freeze=off >>& $KILL_LOG
	endif
endif
echo "After Kill >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>&  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi|$pidcheck" >>& $KILL_LOG
if ($1 == "") echo "GTM processes Killed!"
#=== End Crash ===
