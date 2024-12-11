#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2023-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Portions taken from sudo/gtm7759
#
setenv ydb_msgprefix "GTM"				# So can run the test on GTM releases
echo '# Release note:'
echo '#'
echo '# GT.M restores ZSTEP operations after an asynchronous event such as MUPIP INTRPT or $ZTIMEOUT;'
echo '# previously asynchronous events implicitly removed any pending ZSTEP operations. In addition,'
echo '# a restriction configured for ZBREAK also applies to ZSTEP; previously it did not. If you prefer'
echo '# we separate these restrictions, please let FIS know. (GTM-9324)'
echo
echo '# The first part of this test is to verify the ZSTEP operation is restored after a MUPIP INTERRUPT'
echo '# or a $ZTIMEOUT. We use the ^sstep facility which uses $ZSTEP to trace the execution of a routine'
echo '# printing each line that runs. We have two test routines (testA and testB) that will test both'
echo '# $ZINTERRUPT and $ZTIMEOUT respectively and whether or not ZSTEP tracing resumes after the interrupt'
echo '# returns.'
echo '#'
echo '# The second part of this test will verify that ZBREAK and ZSTEP obey the same restrictions.'
echo
echo '# Create database'
$gtm_tst/com/dbcreate.csh mumps
echo
$echoline
echo
echo '# Part 1 - Verify ZSTEP operation is restored and MUPIP INTERRUPT or $ZTIMEOUT'
echo '# testA: Launch M process to be interrupted while ZSTEPing'
($gtm_dist/mumps -run testA^gtm9324 & ; echo $! >&! mumpspidA.txt) >& mumpspidA.out
set mumpspidA = `cat mumpspidA.txt`
$gtm_dist/mumps -run ^%XCMD 'for i=1:1 quit:$get(^loopcnt1,0)>1  hang .1'	# Wait for loop to become active
echo '# Interrupt process and wait for it to die'
$MUPIP intrpt $mumpspidA	    			# Send interrupt
$gtm_tst/com/wait_for_proc_to_die.csh $mumpspidA 300
echo '# [cat mumpspidA.out]'
cat mumpspidA.out
echo
echo '# testB: Run similar test that uses $ZTIMEOUT instead of $ZINTERRUPT to cause an interrupted ZSTEP'
($gtm_dist/mumps -run testB^gtm9324 & ; echo $! >&! mumpspidB.txt) >& mumpspidB.out
set mumpspidB = `cat mumpspidB.txt`
$gtm_dist/mumps -run ^%XCMD 'for i=1:1 quit:$get(^loopcnt2,0)>1  hang .1'	# Wait for loop to become active
echo '# Wait for process to die'
$gtm_tst/com/wait_for_proc_to_die.csh $mumpspidB 300
echo '# [cat mumpspidB.out]'
cat mumpspidB.out
echo
$echoline
echo
echo '# Part 2 - Verify ZSTEP and ZBREAK obey the same restrictions'
echo
echo '# This part of the test runs in a copy of the current runtime version of YottaDB. This is because'
echo '# we need to add a restrict file to the distribution. First make a copy of the current test version.'
setenv gtm_dist_save $gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist	    # Sets $ydb_dist
setenv gtm_dist $ydb_dist
setenv gtm_exe $gtm_dist
echo
echo '# Now create a restrict.txt file and install it in $gtm_dist. This should prevent us from running'
echo '# any ZSTEP or ZBREAK commands. Note randomly choose ZSTEP or ZBREAK to restrict so cover both.'
cat > restrict.txt << EOF
ZBREAK : ydbtest3
EOF
sudo cp restrict.txt ydb_temp_dist/
sudo chown root:root ydb_temp_dist/restrict.txt
sudo chmod 444 ydb_temp_dist/restrict.txt # Process must not have write access to restrict.txt
sudo chmod 555 ydb_temp_dist              # No updates
# Need a new userid/groupid for this test - create it dynamically - Note spool output for the commands used here
# to a file as some distros give varying responses to these userid and group add/delete commands.
#
# First, check if it the userid and/or group exist already in which case bypass the create.
echo
echo '# Create ydbtest3 group and userid'
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
echo
echo '# Verify that a ZSTEP command works correctly when ZBREAK is restrited'
$gtm_dist/mumps -run verifyzstep^gtm9324 <<EOF
zstep
zstep
zstep
zstep
EOF
echo
echo '# Verify that a ZBREAK command fails with RESTRICTEDOP error'
$gtm_dist/mumps -run ^%XCMD 'zbreak zbrktarget^gtm9324 write "ZBREAK ran unexpectedly successfully",!'
echo
echo '# Verify that when BREAK is restricted (instead of ZBREAK) that doing a ZSTEP INTO command works'
echo '# properly and does not assert fail in a debug build.'
#
# Replace restrict file with one that instead restricts the BREAK command.
#
#sudo chmod 775 ydb_temp_dist		  # Allow updates
#sudo chmod 775 ydb_temp_dist/restrict.txt # Give us write access to file
mv restrict.txt restrict1.txt
cat > restrict2.txt << EOF
BREAK : ydbtest3
EOF
sudo cp restrict2.txt ydb_temp_dist/restrict.txt
sudo chown root:root ydb_temp_dist/restrict.txt
sudo chmod 444 ydb_temp_dist/restrict.txt # Process must not have write access to restrict.txt
sudo chmod 555 ydb_temp_dist              # No updates
$gtm_dist/mumps -run verifyzstepoutof^gtm9324
echo
echo '# Cleanup and remove ydbtest3 userid/group'
sudo chmod -R 775 ydb_temp_dist  # prepare copy of dist directory so it can be cleaned
sudo chown -R $USER ydb_temp_dist
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
setenv gtm_dist $gtm_dist_save
setenv gtm_exe $gtm_dist
echo
$echoline
echo
echo '# Validate DB'
$gtm_tst/com/dbcheck.csh
exit 0
