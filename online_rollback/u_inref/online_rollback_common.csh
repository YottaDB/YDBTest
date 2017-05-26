#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set floor	= $1
set updates	= $2
set waittime	= $3
set method	= $4
set iterations	= $5
if ("" == $method) set method="jnl"
if ("" == $iterations) set iterations=1

while (0 < $iterations)
	if ( -e ONLINE_ROLLBACK.stop ) then
		echo "# Using floor=[$floor] updates=[$updates] waittime=[$waittime] iterations=[$iterations]"		>>&! last_seqno.csh
		echo "# ONLINE_ROLLBACK stopped `date +%H:%M:%S`"
		exit 0
	else if ( -e ONLINE_ROLLBACK.in_progress ) then
		echo "# Using floor=[$floor] updates=[$updates] waittime=[$waittime] iterations=[$iterations]"		>>&! last_seqno.csh
		echo "# ONLINE_ROLLBACK in progress `date +%H:%M:%S`"
		exit 0
	endif

	echo "# Using floor=[$floor] updates=[$updates] waittime=[$waittime] iterations=[$iterations]"		>>&! ONLINE_ROLLBACK.in_progress
	echo "# Using floor=[$floor] updates=[$updates] waittime=[$waittime] iterations=[$iterations]"		>>&! last_seqno.csh

	# wait for at least 800 updates or 120 seconds, whichever comes first
	$gtm_exe/mumps -run waituntilseqno "jnl" $floor $updates $waittime		>>&! last_seqno.csh
	source last_seqno.csh

	# Get the current transaction number
	$gtm_exe/mumps -run jnl^getresyncseqno $floor $method				>>&! roll_seqno.csh
	source roll_seqno.csh

	set ts1 = `date +"%b %e %H:%M:%S"`
	# Online Rollback to $roll_seqno
	echo $gtm_tst/com/mupip_rollback.csh -verbose -online -resync=$roll_seqno "*"	>&! orlbk.outx
	$gtm_tst/com/mupip_rollback.csh -verbose -online -resync=$roll_seqno "*" 	>>&! orlbk.outx
	if ($status != 0) then
		echo "TEST-E-FAILED - ONLINE ROLLBACK failed"
	endif
	$tst_awk -f $gtm_tst/$tst/inref/checkoutput.awk rollseqno=$roll_seqno jnlseqno=$curr_jnl_seqno resyncseqnolist=$curr_resync_seqnos orlbk.outx
	$echoline 								 	>>&! orlbk.outx
	$echoline 								 	>>&! orlbk.outx
	$echoline 								 	>>&! orlbk.outx

	# wait until more updates than were rolledback
	$gtm_exe/mumps -run waituntilseqno "jnl" $lastseqno 50 120			>>&! last_seqno.csh
	source last_seqno.csh

	touch ONLINE_ROLLBACK.done
	@ iterations--
end
echo "${roll_seqno}" >>&! ONLINE_ROLLBACK.complete
