#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# used by gtm6571 to watch for action by gtm6571_procstcukexec.csh
	@ cnt = 3
loop:
	touch mutexlckalert_$cnt
	@ sleepcnt = 90
	while ( -e mutexlckalert_$cnt )
		@ sleepcnt--
		if ( 0 == $sleepcnt ) then
			echo "Timed out while waiting for mutexlckalert_$cnt to be removed"
			exit
		endif
		sleep 1
	end
	@ cnt--
	if ( 0 != $cnt ) goto loop
	echo "gtm6571_procstuckexec ran"
