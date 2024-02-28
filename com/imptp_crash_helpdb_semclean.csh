#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script is invoked by tests that run "imptp.csh" and crash the processes.

# $1 points to the log file to write ipc cleanup messages to
# $2 holds the list of pids (most of which are expected to be imptp jobbed off processes) that were killed
#    and that need to be cross checked for orphaned helpdb semaphores and clean those from the system.

set logfile = "$1"
set pids = "$2"

# It is most likely all of those pids have opened "gtmhelp.dat" (e.g. using $PEEKBYNAME).
# If so, that would have created a private semaphore with a 0 key that is known/used only to/by that imptp process
# (as help databases have READ_ONLY property set in the db file header causing the db to be an MM access method).
# If so, we need to clean up those semaphores too once the imptp process is killed. Or else the "ipcs -s"
# count of the system will keep growing as more such tests run resulting in an eventual "No space left on device"
# error from the semget() system call as part of a database file open.

# It is possible some caller tests invoke "mupip journal -rollback -online" after this script. In that case,
# we should only remove the gtmhelp.dat semids and not mumps.dat semids (or else we would get a %YDB-E-REQROLLBACK
# error (with "%SYSTEM-E-ENO22, Invalid argument" additional error). Therefore, filter out the semids that are
# tracked in the db file header from the list of semids that get removed below.
set dbfilenames = `$gtm_dist/mumps -run getDbFilenames`
set dbsemids = ""
foreach file ($dbfilenames)
	# It is possible there are some AUTODB regions that don't exist. In that case, skip processing them
	if (! -e $file) then
		continue
	endif
	set dbsemid = `$MUPIP dumpfhead $file | $grep semid | sed 's/.*=//;'`
	if ("$dbsemid" != "") then
		set dbsemids = "$dbsemids $dbsemid"
		echo "# imptpcrash_helpdb_semclean.csh : $file : dbsemid = $dbsemid" >>& $logfile
	endif
end

set zero_key_sems = `$gtm_tst/com/ipcs -s | $grep $USER | $tst_awk '$3 == "0x00000000" {print $2;}'`
foreach semid ($zero_key_sems)
	# Check if semid corresponds to a tracked semaphore in the db file header.
	# If so, skip removing it as it won't cause accumulation of semids in the system.
	set found = 0
	foreach dbsemid ($dbsemids)
		if ($semid == $dbsemid) then
			set found = 1
			break
		endif
	end
	if ($found) then
		continue
	endif

	# Each semid corresponds to a semaphore set.
	# Check if semaphore 1 in the semaphore set has a "sempid" matching one of the pids that we killed
	# AND has a "semval" value of 0. If so, that is an orphaned semaphore now and should be cleaned up
	# or else we would have a backlog of these orphaned semaphores with lots of such test runs.
	set semval = `$MUPIP semaphore $semid |& $grep 'sem  1:' | awk '{print $4}' | sed 's/,//;'`
	if (0 == $semval) then
		set sempid = `$MUPIP semaphore $semid |& $grep 'sem  1:' | awk '{print $10}' | sed 's/)//;'`
		foreach pid ($2)
			if ($pid == $sempid) then
				echo "# Cleaning up orphaned MM private gtmhelp.dat semid [$semid] for pid $pid" >>& $logfile
				$gtm_tst/com/ipcrm -s $semid >>& $logfile
			endif
		end
	endif
end
