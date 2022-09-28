#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2020-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Removed FTOK semaphore keys if no ftok collision is detected
# $ftok_key = list of keys in hex
# We assume all $pidall has died
# 	So counter semaphores must be zero.
#	If it is non-zero then
#		do not remove it ( (assuming ftok collision is there)
#	Else
#		Remove
# 	Endif
#
if ($?KILL_LOG == 0) then
	setenv kill_time `date +%H_%M_%S`
	setenv KILL_LOG pkill_${kill_time}.logx
endif
foreach key ($ftok_key)
	# Though Linux has different format semid is still in column 2
	# The "uniq" is needed for an ipcs regression (May 2020) where `ipcs -s` prints 2 (duplicate) lines per semaphore.
	set sem_id = `$gtm_tst/com/ipcs -s | $grep $key | uniq | $tst_awk '{printf("%s ",$2);}'`
	echo "sem_id is "$sem_id >>& $KILL_LOG
	# It cound happen that due to ftok collision, another process removed this semaphore
	# P1 opens DB1,creates FTOK1 and increment the counter semaphore to be 1.
	# P2 opens DB2. Since DB2 has the same ftok value as DB1, it will use the existing FTOK semaphore FTOK1, increments the counter semaphore to be 2.
	# P2 gets kill -9ed. once P2 gets killed, the OS automatically adjusts FTOK1s counter semaphore to be back at 1.
	# P1 decides to shut down, decrements FTOK1s counter semaphore by 1 and notices the counter semaphore is 0 and therefore removes the FTOK semaphore.
	if ( 0 == `echo $sem_id|wc -w` ) then
		echo "TEST-I-sem_id NULL for "$key >>& $KILL_LOG
		echo "It is possible that due to ftok collision, another process removed this semaphore." >>& $KILL_LOG
		continue
	endif
	echo "##semstat info: " >>& $KILL_LOG
	$gtm_exe/semstat2 $sem_id >>& $KILL_LOG
	# It is possible that semstat2 done below might issue an error indicating that the semaphore does not exist.
	# This is possible if some other process concurrently removes the FTOK semaphore (see scenario above).
	# This is not an error condition and we do not want the test to fail. So make sure any error messages from the
	# semstat2 will not go to stdout. Hence the |& (instead of a simple |) in the pipe below.
	set tsemval = `$gtm_exe/semstat2 $sem_id |& $grep "sem  1" | $tst_awk '{print($3);}' | sed 's/(semval=//' | sed 's/,//'`
	if ($tsemval == 0) then
		echo "TEST-I-$gtm_tst/com/ipcrm -S $key"  >>& $KILL_LOG
		$gtm_tst/com/ipcrm -S $key	>>& $KILL_LOG
	else
		echo "TEST-I-Did not remove semphore $key because of tsemval ($tsemval)"  >>& $KILL_LOG
	endif
end
