#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013, 2015 Fidelity National Information	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# This test is a collection of scenarios to verify that the new logic that takes care of      #
# journal buffer size validation and auto-adjustment works as intended.                       #
###############################################################################################

if ($gtm_test_jnl_nobefore) then
	# nobefore image randomly chosen
	set b4nob4image = "nobefore"
else
	# before image randomly chosen
	set b4nob4image = "before"
endif

# Get the current limits
source $gtm_tst/com/set_limits.csh

# Pick some predetermined buffer sizes for further use in this script
@ low_buffer_size = $MIN_JOURNAL_BUFFER_SIZE / 2
@ lower_buffer_size = $low_buffer_size / 2
@ valid_buffer_size = $MIN_JOURNAL_BUFFER_SIZE * 2

# Create a simple alias for checking the journaling state
alias check_journaling '$DSE dump -file |& $grep -i journal | $grep -E "Buffer|State" | $tst_awk '"'"'{print $1" "$2" "$3" "$4}'"'; echo"

###############################################################################################
# Case 1. Specifying an explicit low buffer size value when enabling, turning on, and turning #
# off journaling via MUPIP set -journal command.                                              #
###############################################################################################
echo "Case 1."
echo

# Create a database
$gtm_tst/com/dbcreate.csh mumps
echo

# We should get a warning message that the value specified is too low, and another, informational
# message that the journal buffer size has been adjusted to the current minimum
$MUPIP set -journal=enable,off,buffer_size=$low_buffer_size -file mumps.dat
echo

# Check the journaling state
check_journaling

# We should get the same messages as above
$MUPIP set -journal=$b4nob4image,on,buffer_size=$low_buffer_size -file mumps.dat
echo

# Check the journaling state
check_journaling

# We should get the same messages as above
$MUPIP set -journal=off,buffer_size=$low_buffer_size -file mumps.dat
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case1 "" mv

$echoline

###############################################################################################
# Case 2. Enabling, disabling, and re-enabling journaling with default values.                #
###############################################################################################
echo "Case 2."
echo

# Create a database
$gtm_tst/com/dbcreate.csh mumps
echo

# We should not see any error or warning messages
$MUPIP set -journal=enable,on,$b4nob4image -file mumps.dat
echo

# Check the journaling state
check_journaling

# This operation should also be clean
$MUPIP set -journal=disable -file mumps.dat
echo

# Check the journaling state
check_journaling

# We should not see any warnings or errors this time either
$MUPIP set -journal=enable,on,$b4nob4image -file mumps.dat
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case2 "" mv

$echoline

# The rest of the cases below require a prior version.
# Exit the subtest now if the platform/host does not have prior version
if ($?gtm_test_nopriorgtmver) then
	exit
endif

###############################################################################################
# Case 3. Setting a low journal buffer size with an older GDE and ensuring that the value     #
# gets auto-adjusted and utilized on subsequent MUPIP create.                                 #
###############################################################################################
echo "Case 3."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 3

# Set a low journal buffer size in the global directory
cat > setlowbuffer.gde <<EOF
  change -region DEFAULT -journal=(${b4nob4image}_image,buffer_size=$low_buffer_size)
  exit
EOF
$GDE_SAFE @setlowbuffer.gde

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit
echo

# Create a database. We should not see any errors; journaling should be enabled;
# and the buffer size should be at new default.
$MUPIP create
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcreate

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case3 "*.dat *.gld" mv

$echoline

###############################################################################################
# Case 4. Setting a low journal buffer size with an older MUPIP version and ensuring that the #
# value gets auto-adjusted on an update in the current version, at the shared-memory-         #
# allocation time.                                                                            #
###############################################################################################
echo "Case 4."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 4

# Create a global directory
$GDE_SAFE exit
echo

# Create a database
$MUPIP create
echo

# Enable journaling with a journal buffer size below the current minimum
$MUPIP set -journal=enable,on,$b4nob4image,buffer_size=$low_buffer_size -file mumps.dat
echo

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit

# Remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# Try to write an update. We should not see any messages at this point, except in the syslog,
# about journal buffer size being adjusted to the new minimum.
$GTM -direct <<EOF
  set ^x=1
EOF

echo

# Remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# Verify that JNLBUFFREGUPD message is printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "journal_buffer_adjust4.txt" "" "JNLBUFFREGUPD"
if ($status) then
	echo "TEST-E-FAIL JNLBUFFREGUPD not found in operator log. Check journal_buffer_adjust4.txt."
	echo
endif

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case4 "" mv

$echoline

###############################################################################################
# Case 5. Setting a low journal buffer size with an older MUPIP version and verifying that in #
# the current version the value gets properly auto-adjusted even if an invalid value is       #
# explicitly specified in a MUPIP set command.                                                #
###############################################################################################
echo "Case 5."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 5

# Create a global directory
$GDE_SAFE exit
echo

# Create a database
$MUPIP create
echo

# Enable journaling with a journal buffer size below the current minimum
$MUPIP set -journal=enable,on,$b4nob4image,buffer_size=$low_buffer_size -file mumps.dat
echo

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit
echo

# Move an older-generation journal file out of the way
\mv mumps.mjl mumps.mjl.old

# Try setting the buffer size to an even lower value. We should get a warning message about
# the buffer size specified being too low, and another, informational message that it has
# been adjusted to the new minimum.
$MUPIP set -journal=enable,on,$b4nob4image,buffer_size=$lower_buffer_size -file mumps.dat
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case5 "" mv

$echoline

###############################################################################################
# Case 6. Setting a low journal buffer size with an older MUPIP version and verifying that in #
# the current version when specifying an explicit new value in an invalid (due to journal-    #
# buffer-unrelated setting) MUPIP set command, the journal buffer size gets auto-adjusted to  #
# the minimum and not default value.                                                          #
###############################################################################################
echo "Case 6."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 6

# Create a global directory
$GDE_SAFE exit
echo

# Create a database
$MUPIP create
echo

# Enable journaling with a journal buffer size below the current minimum
$MUPIP set -journal=enable,on,$b4nob4image,buffer_size=$low_buffer_size -file mumps.dat
echo

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit
echo

# Move an older-generation journal file out of the way
\mv mumps.mjl mumps.mjl.old

# Back up the database file
cp mumps.dat mumps.dat.bak

# Try setting both an invalid align size (first) and a valid buffer size (second) that is different
# from the default. We should get an error message about the align size specified being too low.
# The buffer size should remain at the old value.
$MUPIP set -journal=enable,on,$b4nob4image,align=1,buffer_size=$valid_buffer_size -file mumps.dat
echo

# We cannot use DSE this time to check the state of journaling since it calls db_init, which
# would case the auto-adjustment of journal buffer size. Instead, we will verify the fact
# that no updates should have been made to the actual database file.
diff mumps.dat mumps.dat.bak

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case6 "" mv

$echoline

###############################################################################################
# Case 7. Setting a low journal buffer size with an older MUPIP version and verifying that    #
# reenabling journaling in the current version with no explicit settings (that is, all left   #
# at default), the journal buffer gets auto-adjusted to the current minimum.                  #
###############################################################################################
echo "Case 7."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 7

# Create a global directory
$GDE_SAFE exit
echo

# Create a database
$MUPIP create
echo

# Enable journaling with a journal buffer size below the current minimum
$MUPIP set -journal=enable,on,$b4nob4image,buffer_size=$low_buffer_size -file mumps.dat
echo

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit
echo

# Move an older-generation journal file out of the way
\mv mumps.mjl mumps.mjl.old

# Remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# Try simply switching a journal file by reenabling already enabled journaling. The buffer size
# should get adjusted to the new minimum, about which we should get a message in the syslog
$MUPIP set -journal=enable,on,$b4nob4image -file mumps.dat
echo

# Remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# Verify that JNLBUFFREGUPD message is printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "journal_buffer_adjust6.txt" "" "JNLBUFFREGUPD"
if ($status) then
	echo "TEST-E-FAIL JNLBUFFREGUPD not found in operator log. Check journal_buffer_adjust6.txt."
	echo
endif

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Prepare for the next case
$gtm_tst/com/backup_dbjnl.csh case7 "" mv

$echoline

###############################################################################################
# Case 8. Creating an unjournaled older-version database and verifying that upon switching to #
# the current version and writing an updated the auto-adjustment of journal buffer size       #
# happens prior to allocating shared memory.                                                  #
###############################################################################################
echo "Case 8."
echo

# Switch to a previous version
source $gtm_tst/$tst/u_inref/set_low_jnl_buff_prior_ver.csh 8

# Create a global directory
$GDE_SAFE exit
echo

# Create a database
$MUPIP create
echo

# Switch back to the current version
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image

# Upgrade the global directory
$GDE exit
echo

# Remember the start time
set time_before = `date +"%b %e %H:%M:%S"`

# Try to write an update. We should not see any messages at this point, except in the syslog,
# about journal buffer size being adjusted to the new minimum.
$GTM -direct <<EOF
  set ^x=1
EOF

echo

# Remember the end time
set time_after = `date +"%b %e %H:%M:%S"`

# Verify that JNLBUFFREGUPD message is printed in the syslog
$gtm_tst/com/getoper.csh "$time_before" "$time_after" "journal_buffer_adjust8.txt" "" "JNLBUFFREGUPD"
if ($status) then
	echo "TEST-E-FAIL JNLBUFFREGUPD not found in operator log. Check journal_buffer_adjust8.txt."
	echo
endif

# Enable journaling so that DSE dump will include the journal buffer size
$MUPIP set -journal=enable,on,$b4nob4image -file mumps.dat
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Back up the last case's files for consistency
$gtm_tst/com/backup_dbjnl.csh case8 "*.dat *.gld" mv

$echoline

###############################################################################################
# Case 9. Specifying the maximum possible journal buffer size in GDE and ensuring that this   #
# value is not increased when rounding up for block multiples happens.                        #
###############################################################################################
echo "Case 9."
echo

# Set the maximum journal buffer size in the global directory
$GDE <<EOF
  change -region DEFAULT -journal=(${b4nob4image}_image,buffer_size=$MAX_JOURNAL_BUFFER_SIZE)
  exit
EOF

# Figure out a value above 4 that is not a divider of maximum journal buffer size.
# Then prepare that value times 512.
@ mult = 4
while ($MAX_JOURNAL_BUFFER_SIZE % $mult == 0)
	@ mult = $mult + 1
end
@ block_size = 512 * $mult

# Set a block of the above size, so that the block_size/512 ratio would not
# be a divider of the buffer size value, and it would have to be rounded up
$GDE <<EOF
  change -segment DEFAULT -block=$block_size
  exit
EOF

# Create a database
$MUPIP create
echo

# Check the journaling state
check_journaling

# Check the database
$gtm_tst/com/dbcheck.csh	# MUPIP create done instead of dbcheck

# Back up the last case's files for consistency
$gtm_tst/com/backup_dbjnl.csh case9 "*.dat *.gld" mv
