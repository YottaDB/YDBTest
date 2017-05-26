#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2008-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# D9I10002706 Nested fprintf calls lead to infinite loop of messages in util_output

# The purpose of this test is to trigger cases where a MUPIP STOP gets delivered while MUPIP REORG is in the middle of
# logging output (in util_output). The signal handler will also try to log a different message. We have seen that
# the nested message keeps repeating indefinitely in some rare cases. (D9I10-002706). This should be fixed now.

$gtm_tst/com/dbcreate.csh . -key=200

echo "Create lots of globals (this way ensuring MUPIP REORG has lots of output to do)"
$GTM << GTM_EOF
	set local=0	; we only want global variables
	do set^lotsvar
GTM_EOF

$GTM << GTM_EOF
	do time1^d002706
GTM_EOF

echo "Find out time taken by 1 reorg on the current host"
@ num = 0
$MUPIP reorg >& mupip_reorg_$num.log

$GTM << GTM_EOF
	do time2^d002706
GTM_EOF

# At this point "onereorgtime.txt" will contain the time in seconds that the above reorg took.
# This will be used as the maximum wait by the below script to decide when to randomly issue the MUPIP STOP for future reorgs.
set maxwait = `cat onereorgtime.txt`
echo "Time taken by 1 reorg is : $maxwait seconds"

# in case the reorg completed within 1 second, keep the maxwait at a minimum of 1
if ($maxwait == 0) then
	@ maxwait = $maxwait + 1
endif
# Do not set maxwait to more than 15 as we want at least 4 MUPIP STOPs to occur within the 1 minute window of the test
if ($maxwait > 15) then
	@ maxwait = 15
endif

echo "Adjusted value of maxwait = $maxwait seconds"

echo "Start M program that does kills followed by global set/kill in the background (will run for 1 minute)."
echo "# This ensures MUPIP REORG (started below) has lots of work to do."
$GTM << GTM_EOF
	do start^d002706	; this will stop after 1 minute
GTM_EOF

@ success = 0
@ wait = 0
echo "Start reorg in background and issue MUPIP STOP to it. Keep doing this until GT.M process signals us to stop."
set maxnum = 100 # Do not allow more than 100 iterations of the loop below (to avoid infinite loops just in case)
while (! -e REORG_DONE.TXT)
	@ num = $num + 1
	if ($num > $maxnum) then
		echo "$num iterations of loop done and REORG_DONE.TXT not yet created" >& max.log
		break
	endif
	$gtm_tst/$tst/u_inref/d002706_bkgrnd.csh $num >& bkgrnd_mupip_reorg_$num.log
	# since the process id could already be done, save the output in tmp_pid which could include: <pid> done
	set tmp_pid = `$tst_awk '{print $2}' bkgrnd_mupip_reorg_$num.log`
	# now get the first field which will be the pid
	@ pid = `echo $tmp_pid | $tst_awk '{print $1}'`
	if ($pid == 0) then
		echo "pid = 0 : Test fail"
		# Cannot break because we need to wait for D002706_DONE.TXT to be created by the background GT.M process
		continue
	endif
	echo $wait >& sleeptime_$num.log
	sleep $wait
	$MUPIP stop $pid >& mupip_stop_$num.log
	# Wait for a max of 60 seconds for pid to die. This way if pid goes into an infinite loop (possible in
	# earlier versions of GT.M without this TR fix) the test will fail without being hung indefinitely.
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 120
	@ wait = $wait + 1
	if ($wait > $maxwait) then
		@ wait = 0
	endif
end

$GTM << GTM_EOF
	do wait^job
GTM_EOF

echo "Checking how many FORCEDHALT message we see. We want it to be at least 1"
@ numforcedhalt = `$grep FORCEDHALT mupip_reorg_*.logx | wc -l`
echo "Number of MUPIP REORGs that were successfully MUPIP STOPped is : $numforcedhalt"

# Do integ check. Since MUPIP REORG is MUPIP STOPped, there is a possibility of MUKILLIP, DBMRKBUSY integ
# errors (possible if reorg got killed in the middle of a coalesce that is freeing up blocks). So filter them out.
$gtm_tst/com/dbcheck_filter.csh

