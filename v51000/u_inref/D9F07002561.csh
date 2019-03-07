#!/usr/local/bin/tcsh
#################################################################
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# This module is derived from FIS GT.M.
#################################################################

#
# D9F07-002561 Use heartbeat timer to check and close open older generation journal files (Unix only issue)
#
$gtm_tst/com/dbcreate.csh mumps
$MUPIP set $tst_jnl_str -region "*" >&! mupip_set_jnl.out
$grep "YDB-I-JNLSTATE" mupip_set_jnl.out

# Start 15 GT.M processes in background that sleeps random seconds before opening the journal file.
$GTM << GTM_EOF
        do startjob^d002561
        quit
GTM_EOF

# Create multiple generations of journal files by switching every second for 10 seconds.
@ num = 0
while ($num < 10)
	sleep 1
	date >& date_${num}.out
	$MUPIP set $tst_jnl_str -reg "*" >& jnlswitch_${num}.out
	@ num = $num + 1
end

# Wait for all but the last GT.M thread to have opened journal files (older or latest generation)
$GTM << GTM_EOF
        do waitallbutone^d002561
        quit
GTM_EOF

$fuser *.mjl* >& fuser0.out

# At this point different GT.M processes will have different generations of journal files open.
# And there is one jobbed off GT.M process waiting for our signal so it can open the latest generation journal file.
# Send it that signal by setting the appropriate global.
$GTM << GTM_EOF
        do sendsignal^d002561
        quit
GTM_EOF

# Wait for last thread to have opened the latest generation journal file
$GTM << GTM_EOF
        do waitlast^d002561
        quit
GTM_EOF

# Randomly decide to switch journal files one more time.
# If we decide NOT to switch now, we need to later check that there is at least one process having the latest
#	generation journal file open. This is to test that the fixes DO NOT incorrectly close the latest generation
#	journal file.
# If we decide to switch now, we need to allow for the fact that there could be NO process having the latest
#	generation journal file open.
#
set rand = `$gtm_exe/mumps -run rand 2`
echo $rand >! rand.out
if ($rand == 1) then
	$MUPIP set $tst_jnl_str -reg "*" >& jnlswitch_${num}.out
endif

# Wait for approx. 1 minute and check that
#	1) All those GT.M processes that have older journal files open have closed them.
#	2) All those GT.M processes that have latest generation journal files open have them open even after the wait.
# The 1 minute wait is approximate since the heartbeat timer is once every 8 seconds and the journal file check is
#	is done by GT.M every 8th timer. That means a maximum of 64 seconds before GT.M will check the journal files.
# 	Just to be safe, we are sleeping a little more.
date >& date_pre_sleep.out
set echo
sleep 75
unset echo
date >& date_post_sleep.out

echo "----------------------------------------------------------------------------"
echo "Checking that ALL older generation journal files are closed."
set pass=1
foreach file (mumps.mjl_*)
	set logfile=fuser_${file:e}.txt
	# We have seen occasional errors of the form "Cannot stat file /proc/27478/fd/12: No such file or directory".
	# Such errors are considered a fuser issue (with not handling concurrent file deletes/removes). As long as we
	# dont see any output of the form mumps.mjl_*: we assume there is NO process accessing the journal file.
	$fuser $file |& grep $file >& $logfile
	set firstpid = `$tst_awk '{print $2}' $logfile`
	if ("$firstpid" != "") then
		# at least one pid attached to older generation journal file. Error.
		cat $logfile
		set pass=0
	endif
end
if ($pass == 1) then
	echo "PASS from check"
else
	$fuser *.mjl* >& fuser1.out
	echo "FAIL from check"
endif

echo "----------------------------------------------------------------------------"
echo "Checking how many processes have latest generation journal file open."
set pass=1
set file="mumps.mjl"	# latest generation
set logfile=fuser_${file:e}.txt
# We have seen occasional errors of the form "Cannot stat file /proc/22224/fd/16: Stale NFS file handle".
# Such errors are considered a fuser issue (with not handling concurrent file deletes/removes). As long as we
# dont see any output of the form mumps.mjl: we assume there is NO process accessing the latest generation journal file.
$fuser $file |& grep $file >& $logfile
set firstpid = `$tst_awk '{print $2}' $logfile`
if ($rand == 1) then
	if ($firstpid != "") then
		# some pid attached to latest generation journal file. Error.
		set pass=0
	endif
else
	if ($firstpid == "") then
		# no pid attached to latest generation journal file. Error.
		set pass=0
	endif
endif
if ($pass == 1) then
	echo "PASS from check"
else
	$fuser *.mjl* >& fuser2.out
	echo "FAIL from check"
endif

echo "----------------------------------------------------------------------------"

$GTM << GTM_EOF
	do waitjob^d002561
	quit
GTM_EOF

# Check that all jobbed processes did write their final update (to ^final) to the latest generation journal files
# To do that grep for "final" in the journal extract file and sort the output to account for different ordering of writes.
$MUPIP journal -extract -forward -noverify -fences=none mumps.mjl >& jnl_extract.out
echo "grep final mumps.mjf"
$grep final mumps.mjf | $tst_awk -F\\ '{printf "%s\n", $NF;}' | sort

$gtm_tst/com/dbcheck.csh
