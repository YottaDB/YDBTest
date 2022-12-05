#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

echo "# Create MSR framework test environment"
$MULTISITE_REPLIC_PREPARE 2

echo "# Create database files on source and receiver side"
$gtm_tst/com/dbcreate.csh mumps

echo "# Start replication servers on source and receiver side"
$MSR START INST1 INST2

echo "# Wait for the replication servers to be up"
get_msrtime
$MSR RUN INST2 '$gtm_tst/com/wait_for_log.csh -log RCVR_'${time_msr}'.log -message "New History Content"'

echo "# Kill all processes accessing the database on source side."
echo "# fuser *.dat" >>& kill.log
fuser *.dat >>& kill.log
echo "# fuser *.repl" >>& kill.log
fuser *.repl >>& kill.log
echo "# fuser -k *.dat" >>& kill.log
fuser -k *.dat >>& kill.log
echo "# fuser -k *.repl" >>& kill.log
fuser -k *.repl >>& kill.log

echo "# Kill all processes accessing the database on receiver side."
$MSR RUN INST2 'fuser *.dat *.repl RCVR*.log >>& kill.log; fuser -k *.dat *.repl RCVR*.log >>& kill.log;'

echo "# Start time for monitoring syslog"
set syslog_start = `date +"%b %e %H:%M:%S"`

echo "# Run argumentless mupip rundown. Use -override to avoid MUUSERLBK errors. Redirect output to [rundown.log]."
$MUPIP rundown -override >& rundown.log

echo "# Capture all syslog messages from the start time into file [syslog.txt]."
$gtm_tst/com/getoper.csh "$syslog_start" "" syslog.txt

echo -n "# Number of SHMREMOVED and SEMREMOVED messages in mupip rundown output = "
grep -c -E "SEMREMOVED|SHMREMOVED" rundown.log

echo "# Verify SHMREMOVED and SEMREMOVED messages in mupip rundown output MATCH that in the syslog"
grep REMOVED rundown.log >& removed1.log
grep REMOVED syslog.txt | sed 's,.*%YDB-,%YDB-,;s, -- generated.*,,;' >& removed2.log
diff removed1.log removed2.log
if ($status) then
	echo "FAIL : Messages don't match. [diff removed1.log removed2.log] is the diff list."
else
	echo "PASS"
endif

echo "# Filter out known possible %YDB-W- and %YDB-E- messages from argumentless mupip rundown output"
echo "# In the argumentless mupip rundown output, it is possible to see any of the following."
echo "# a) %YDB-W-MUNOTALLSEC if non-YottaDB ipcs owned by user ids other than the current userid (that is running this test)"
echo "#    exist on the system."
echo "# b) %YDB-E-VERMISMATCH messages if YottaDB ipcs created by a different YottaDB release than the one running this test"
echo "#    exist on the system."
echo "# c) %YDB-E-MUJPOOLRNDWNFL messages if YottaDB journal pool ipcs left over from tests run by user ids other than the"
echo "#    current user id exist on the system."
echo "# d) %YDB-E-MURPOOLRNDWNFL messages if YottaDB receive pool ipcs left over from tests run by user ids other than the"
echo "#    current user id exist on the system."
echo "# e) %YDB-E-MUFILRNDWNFL2 messages if YottaDB database ipcs created by a different YottaDB release than the one running"
echo "#    this test exist on the system"
echo "# So filter all of the above out to avoid non-deterministic reference file."

# Since the errors should not be caught by the error catching test framework, redirect the output to .logx (not .log)
# as otherwise we will see TEST-E-ERRORNOTSEEN messages.
$gtm_tst/com/check_error_exist.csh rundown.log "%YDB-W-MUNOTALLSEC" >& rundown1.logx
$gtm_tst/com/check_error_exist.csh rundown.log "%YDB-E-VERMISMATCH" >& rundown2.logx
$gtm_tst/com/check_error_exist.csh rundown.log "%YDB-E-MUJPOOLRNDWNFL" >& rundown3.logx
$gtm_tst/com/check_error_exist.csh rundown.log "%YDB-E-MURPOOLRNDWNFL" >& rundown4.logx
$gtm_tst/com/check_error_exist.csh rundown.log "%YDB-E-MUFILRNDWNFL2" >& rundown5.logx

