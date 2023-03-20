#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# wait for $1 seconds, $2 shows RECOVER or ROLLBACK
#
# Wait time may be shortened based on transaction count or disk space consumed
# to avoid filling the disk on fast machines.
set echo
set sleepduration = $1
set timestamp = `date +%H_%M_%S`
echo "The time is:" `date`
if ("RECOVER" == "$2") then
	# Allow up to 10 MB per second, which is more than a slow machine will produce,
	# but somewhat less than what a fast machine can.
	@ spacelimit = $sleepduration * 10000
	set du_out=`du -sk .`
	@ startspace = $du_out[1]
	while (0 < $sleepduration)
		if ($sleepduration > 5) then
			sleep 5
			@ sleepduration = $sleepduration - 5
			# Check the space used every five seconds
			set du_out=`du -sk .`
			@ addedspace = $du_out[1] - $startspace
			if ( $addedspace > $spacelimit ) break
		else
			sleep $sleepduration
			@ sleepduration = 0
		endif
	end
else
	# Stop and start the passive source server multiple times so that we get multiple history records.
	# There will be at least 5 history records (possibly more due to random)
	@ itera = $sleepduration / 5
	# set a minimum so that we don't wait for very long, since each iteration below
	# takes a significant time as well
	@ iteramin = $sleepduration / 10
	# Instead of just sleeping, wait for the number of transactions to appear in the source log, and use
	# the sleep time as a wait limit.
	# This number is the multiplier for the number of transactions to expect in a second, which is set to be
	# more than what a slow machine can produce, but somewhat less than what a fast machine can.
	@ tps = 5000
	@ count = 1
	while (0 < $sleepduration)
		echo "The time is:" `date`
		# STOP/START
		echo "The iteration is: $count"			>>&! shutdown.out
		$gtm_tst/com/endtp.csh				>>&! shutdown.out
		echo "The time is:" `date`
		$MUPIP replicate -source -shutdown -timeout=0	>& SHUT_${timestamp}_$count.out
		if ($status) then
			echo "TEST-E-SHUTDOWN, see shutdown_${timestamp}_$count.log"
		endif
		echo "The time is:" `date`
		$gtm_tst/com/passive_start_upd_enable.csh	>& START_${timestamp}_$count.out
		echo "The time is:" `date`
		$gtm_tst/com/imptp.csh				>&! imptp_$count.out
		source $gtm_tst/com/imptp_check_error.csh imptp_$count.out; if ($status) exit 1
		echo "The time is:" `date`
		# sleep a random duration, but at least 1 second:
		@ randsleep = `$gtm_exe/mumps -run rand $itera ` + $iteramin
		echo "will sleep another $randsleep seconds..."
		echo "The time is:" `date`
		@ transcount = ${randsleep} * ${tps}
		$gtm_tst/com/wait_for_transaction_seqno.csh +${transcount} SRC ${randsleep} "" "noerror"
		echo "The time is:" `date`
		@ sleepduration = $sleepduration - $randsleep
		@ count = $count + 1
		echo "The time is:" `date`
	end
endif
echo "The time is:" `date`
