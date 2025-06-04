#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;'
********************************************************************************************
GTM-F221672 - Test the following release note
********************************************************************************************

Release note (from http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.1-001_Release_Notes.html#GTM-DE506361)

GTMSECSHR appropriately handles a rare condition when two processes attempt to start a GTMSECSHR process at a coincident time. Previously, this could start more than one GTMSECSHR process, and, although a single GTMSECSHR process handled all the requests, their shutting down produced syslog error messages. (GTM-DE506361)

CAT_EOF
echo

setenv ydb_msgprefix "GTM"
set syslog_start = `date +"%b %e %H:%M:%S"`
source $gtm_tst/$tst/u_inref/setinstalloptions.csh      # sets the variable "installoptions" (e.g. "--force-install" if needed)

echo "### Test no GTMSECSHRGETSEMFAIL or GTMSECSHRREMSEMFAIL errors due to gtmsecshr race conditions"
echo "# In v7.1-001, a race condition caused GTMSECSHRGETSEMFAIL or GTMSECSHRREMSEMFAIL errors to appear in the following manner:"
echo "# 1. Two gtmsecshr processes are started at the same time"
echo "# 2. One gtmsecshr process creates the semaphore"
echo "# 3. On exit, the second gtmsecshr incorrectly attempts to close the semaphore, though it doesn't own it"
echo "# 4. GTMSECSHRGETSEMFAIL or GTMSECSHRREMSEMFAIL errors are emitted by the second gtmsecshr process due to its failure to close the semaphore."
echo "# For details, see the following discussions:"
echo "# https://gitlab.com/YottaDB/DB/YDBTest/-/issues/663#note_2515342546"
echo "# https://gitlab.com/YottaDB/DB/YDBTest/-/issues/663#note_2515494884"
echo
echo "## To test the above race condition scenario:"
echo "# Run 2 instances of gtmsecshr_racecondition-gtmde506361.sh simultaneously 50 times"
echo "# to ensure enough chances for the race condition to occur."
echo "# During each run, each instance of gtmsecshr_racecondition-gtmde506361.sh will:"
echo "# 1. Sleep until the other process is ready to begin"
echo "# 2. Start a new gtmsecshr process"
echo "# 3. Sleep for 1 second"
echo "# 4. Kill the new gtmsecshr process"
echo "# Then, check the syslog to confirm that no GTMSECSHRGETSEMFAIL or GTMSECSHRREMSEMFAIL errors were produced."
echo "# Note that this test fails only 25-50% of the time, depending on whether the timing condition for the race condition was reproduced."
foreach i (`seq 1 50`)
	foreach value (A B)
		($sudostr -E $gtm_tst/$tst/u_inref/gtmsecshr_racecondition-gtmde506361.sh $value$i & ; echo $! >&! script$value$i.pid) >&! gtmsecshr$value$i.out
	end
	sleep 1
	touch START
	foreach value (A B)
		while (! -e gtmsecshr$value$i.pid)
			sleep 0.01
		end
		# Loop over the contents of the pid file in case the `ps -ef` call in
		# gtmsecshr_racecondition-gtmde506361.sh picked up both gtmsecshr processes instead of just one
		foreach pid (`cat gtmsecshr$value$i.pid`)
			$gtm_tst/com/wait_for_proc_to_die.csh $pid
		end
	end
	rm START
end

$gtm_tst/com/getoper.csh "$syslog_start" "" test_syslog.txt
grep GTMSECSHRGETSEMFAIL test_syslog.txt
grep GTMSECSHRREMSEMFAIL test_syslog.txt
# cat test_syslog.txt
