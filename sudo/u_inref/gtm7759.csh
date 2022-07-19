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

echo "# Test for GTM-7759 - verify that the new (V63012) LOGDENIALS statement in restrict.txt works correctly."
echo "#"
echo "# This test runs a series of 3 small tests on two userids. The two userids are (1) the user this test was"
echo "# started with and the second is a userid we create (and remove) in this test - ydbtest3. We use 'sudo su'"
echo "# to switch users and record the log of what the test did. The test makes a copy of the YottaDB distro so"
echo "# we can add the restrict.txt file to it. This file contains only a LOGDENIALS statement for group ydbtest3"
echo "# so our expectation is that on runs in the ydbtest3 userid, it will see the error we are testing in the"
echo "# syslog file while runs with the test userid will not see those errors logged. There are a lot of errors"
echo "# which have their messages designated as automatically being logged to syslog. We only test 3 as most of"
echo "# them are significantly difficult to invoke."
echo "#"

# To start, we need a database
$gtm_tst/com/dbcreate.csh mumps
# Need a copy of our current distribution as we need to create a restrict.txt file in it. Note that
# we do not use com/copy_ydb_dist_dir.csh as we need to be able to run gtmsecshr out of it which is
# not possible with this script because it does not preserve uid/permissions.
sudo cp -pr $ydb_dist ydb_temp_dist
setenv gtm_dist $ydb_dist
# Set a LOGDENIALS ydbtest3 so that auto-logged permission issues only happen for ydbtest3
cat > restrict.txt << EOF
LOGDENIALS : ydbtest3
EOF
sudo cp restrict.txt ydb_temp_dist/
sudo chown root:root ydb_temp_dist/restrict.txt
sudo chmod 444 ydb_temp_dist/restrict.txt # Process must not have write access to trigger restrictions
sudo chmod 555 ydb_temp_dist              # No updates
# Need a new userid/groupid for this test - create it dynamically - Note spool output for the commands used here
# to a file as some distros give varying responses to these userid and group add/delete commands.
#
# First, check if it the userid and/or group exist already in which case bypass the create.
echo
echo '# Create ydbtest3 group and userids'
$grep -q ydbtest3 /etc/group              # Quietly see if the group exists
set savestatus = $status
if (0 == $savestatus) then
    echo 'The ydbtest3 group already exists'
else if (1 == $savestatus) then           # Does not exist, create it now
    sudo groupadd ydbtest3 >& groupadd.log
    set savestatus = $status
    if (0 != $savestatus) then
	echo "TEST-F-GROUPADDFAIL The groupadd command for ydbtest3 failed with rc $savestatus"
	exit 1
    endif
    echo 'The ydbtest3 group has been created'
else
    echo "Unknown error from $grep: $savestatus"
endif
# Now do similar for the userid
$grep -q ydbtest3 /etc/passwd
set savestatus = $status
if (0 == $savestatus) then
    echo 'The ydbtest3 userid already exists'
else if (1 == $savestatus) then           # Does not exist, create it now
    sudo useradd --gid ydbtest3 --no-log-init --no-create-home -d `pwd` ydbtest3 >& useradd.log
    set savestatus = $status
    if (0 != $savestatus) then
	echo "TEST-F-USERADDFAIL The useradd command for ydbtest3 failed with rc $savestatus"
	exit 1
    endif
    echo 'The ydbtest3 userid has been created'
else
    echo "Unknown error from $grep: $savestatus"
endif
# Loop through the errors we want to process
set errorlist = "ZGBLDIRACC DBPRIVERR SETZDIR"
foreach error ($errorlist)
    set userlist = "ydbtest3 $USER"
    foreach user ($userlist)
	echo
	echo "## Testing user $user with test $error"
	# remember the start time
	set time_before = `date +"%b %e %H:%M:%S"`
	sleep 1 # Make sure on a 1 sec boundary
	drivescript.csh $user ./test${error}.sh ydb_temp_dist
	sleep 1
	set time_after = `date +"%b %e %H:%M:%S"`
	# Extract the syslog for this run
	$gtm_tst/com/getoper.csh "$time_before" "$time_after" "syslog-${error}-${user}.txt"
	# Isolate the PID that ran the test so we can look for it in the syslog file
	set drivePID = `awk '/DrivePID:/ {print $2}' drivescript_test${error}.sh_${user}.logx`
	# If an error occurred during the run, make sure it is also for the correct PID
	grep -e "$error" syslog-${error}-${user}.txt | grep -e "\[$drivePID\]"
    end
end
echo
echo '# Cleanup and remove ydbtest3 userid/group'
sudo chmod -R 775 ydb_temp_dist  # prepare copy of dist directory so it can be cleaned
sudo chown -R $USER ydb_temp_dist
sudo chmod 664 mumps.dat # In case an earlier permission revert got bypassed due to error
# Note - we use userdel here to remove both the userid and the group. This functionality is the default in all distros
# we have checked. If the /etc/login.defs file has a USERGROUPS_ENAB statement set to 'yes', then userdel will delete
# the group by the same name so long as the group has no more members.  Again, spool the output to a file for both
# the userid and group removals as the output differs amongst distros.
sudo userdel ydbtest3 >& userdel.log  # Remove userid added earlier (also usually removes group of same name)
set savestatus = $status
if (0 != $savestatus) echo "## The userdel command for ydbtest3 failed with rc $savestatus"
# On a system without USERGROUPS_ENAB turned on, the ydbtest3 group will be left out. Check for that and do a groupdel
# command on it if so.
$grep -q ydbtest3 /etc/group              # Quietly see if the group exists
if (0 == $status) then                    # Group exists - try to remove it
    sudo groupdel ydbtest3 >& groupdel.log
    set savestatus = $status
    if (0 != $savestatus) echo "## The groupdel command for ydbtest3 failed with rc $savestatus"
endif
echo
echo '# Validate lightly used DB'
$gtm_tst/com/dbcheck.csh
exit 0
