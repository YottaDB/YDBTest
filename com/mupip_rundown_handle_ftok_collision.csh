#!/usr/local/bin/tcsh -f
#################################################################
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
# This script runs a MUPIP RUNDOWN command passed in by the caller with the ability to retry the command in case of
# ftok collisions on the db file. That would cause an error like the following.
#	%SYSTEM-E-ENO11, Resource temporarily unavailable
# This retry logic helps avoid false test failures.
#

set iters = 300	# retry with sleep-loop for 5 minutes
set noglob	# do this in case $* contains "*". We do not want the * to be expanded by the shell.
while ($iters > 0)
	set logfile = rundown_collision_$$_${iters}.logx
	$MUPIP rundown $* >& $logfile
	if ($status) then
		$grep "%SYSTEM-E-ENO11, Resource temporarily unavailable" $logfile >& /dev/null
		if (0 == $status) then
			sleep 1
			@ iters = $iters - 1
			continue
		endif
	endif
	break
end
unset noglob

if ($iters == 0) then
	# Time out case
	echo "MUPIP_RUNDOWN_HANDLE_FTOK_COLLISION-E-TIMEOUT : Current time is `date`"
endif

# Note that we cat the latest logfile in case of a successful break out of the above while loop as well as for
# the case when we timed out in the sleep-loop.
cat $logfile
