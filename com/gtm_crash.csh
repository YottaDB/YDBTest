#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
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
setenv kill_time `date +%H_%M_%S`
setenv KILL_LOG pkill_${kill_time}.logx

echo "Before Kill >>>>" >>& $KILL_LOG
$gtm_tst/com/ipcs -a | $grep $USER >>  $KILL_LOG
$psuser | $grep -E "mupip|mumps|simpleapi" >>& $KILL_LOG

# PID for mumps
set pids=`$tst_awk '$1 ~ /PID/ {print $2}' *${gtm_test_jobid}.mjo*`
set pidcheck = "${pids:as/ /|/}"

# IPCS
set db_ftok_key = `$gtm_exe/ftok -id=43 *.dat| $tst_awk '/dat/{print $5}'`
setenv ftok_key "$db_ftok_key"
if ($1 == "NO_SHM_REM") then
	set dbipc_private = ""
	foreach file (*.dat)
		set ipc = `$MUPIP ftok $file | $tst_awk '/dat/{printf("-s %s",$3);}'`
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
$gtm_tst/com/rem_ftok_sem.csh # arguments $ftok_key
# Collecting the IDs of relinkctl shared memory segments from the RCTLDUMP is prohibitive, so clean directly.
$MUPIP rundown -relinkctl >>& $KILL_LOG
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
