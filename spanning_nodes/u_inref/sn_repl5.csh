#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#############################################################################################################
# This test is similar to spanning_nodes/sn_jnl4 but with only one run instead of ten. In that run we       #
# select a random version starting with V60000 (so, this is largely a 'future' test) and try three          #
# different scenarios, each of which should cause the secondary's update process to fail. In the first      #
# scenario set the secondary's max key size to 32, and on the primary write a global with the unsubscripted #
# key of length 33. In the second scenario we let the secondary's max key size be of default value, and on  #
# the primary write a global with subscripts in the key, whose total length exceeds the secondary's         #
# maximum. Finally, in the third scenario we let the secondary's max record size be default, and on the     #
# primary write a global whose value exceeds the secondary's maximum. Every time we expect an appropriate   #
# error to be printed.                                                                                      #
#############################################################################################################

echo "Verify that replication filters properly generate key- and record-size-related errors between an older and current version"
echo

# The test does most of the database/replication setup all by itself (by invoking dbcreate_base.csh). If $gtm_custom_errors
# is set, the MUPIP SET operations (done below) will try to open jnlpool and thus access mumps.repl which doesn't exist at
# this point thereby issuing FTOKERR/ENO2 errors. So, unsetenv gtm_custom_errors. While saving and restoring gtm_custom_errors
# is an option, this test does multiple dbcreates so saving and restoring for each dbcreate is an overkill. So, unsetenv the
# environment variable for the entire duration of the test.
unsetenv gtm_custom_errors

if ($?gtm_test_replay) then
	# Get previous limits
	source $gtm_tst/com/set_limits.csh
	@ RAND_REG_COUNT = $gtm_test_rand_reg_count
else
	# Get random limits
	source $gtm_tst/com/set_random_limits.csh
	echo "setenv gtm_test_rand_reg_count $RAND_REG_COUNT" >> settings.csh
endif

# If run with journaling, this test requires BEFORE_IMAGE, so set that unconditionally
source $gtm_tst/com/gtm_test_setbeforeimage.csh

# Because this test uses prior versions that may not handle large alignsize values, remove the alignsize part
setenv tst_jnl_str `echo "$tst_jnl_str" | sed 's/,align=[1-9][0-9]*//'`

# Also disable triggers to avoid complications with previous versions
setenv gtm_test_trigger 0

# Since this test uses prior versions before r1.20, they issue error messages with GTM prefix (not YDB prefix).
# To get this test to pass always, set ydb_msgprefix so versions r1.20 and later also use the same GTM prefix.
setenv ydb_msgprefix "GTM"

if ($?gtm_test_replay) then
	set prior_ver = `echo $gtm_test_rand_prior_ver`
else
	# Pick a random version, possibly even the current one, since we test all filter configurations
	$gtm_tst/com/random_ver.csh -gte V60000 >&! prior_ver.txt
	if (0 != $status) then
		set prior_ver = $tst_ver
		echo $prior_ver >&! prior_ver.txt
	else
		set prior_ver = `cat prior_ver.txt`
	endif
	echo "setenv gtm_test_rand_prior_ver $prior_ver" >> settings.csh
endif
source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver

# Disabled settings that do not work with MSR and prior versions
source $gtm_tst/com/disable_settings_msr_priorver.csh hugepages spanning_regions

# Prepare an MSR configuration with two instances, INST1 and INST2;
# INST1 is the root primary, and INST2 is the secondary.
$MULTISITE_REPLIC_PREPARE 2

# Update the MSR configuration to select a random version on the secondary
cp msr_instance_config.txt msr_instance_config.bak
$tst_awk '{if (("INST2" == $1) && ("VERSION:" == $2)) {sub("'$tst_ver'","'$prior_ver'")} print }' msr_instance_config.txt >&! msr_instance_config.txt1
$tst_awk '{if (("INST2" == $1) && ("IMAGE:" == $2)) {sub("dbg","pro")} print }' msr_instance_config.txt1 >&! msr_instance_config.txt
\rm msr_instance_config.txt1
$MULTISITE_REPLIC_ENV

######################

# Set random limits on the primary instance
setenv gtm_test_sprgde_id "ID1_${RAND_REG_COUNT}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT $MAX_KEY_SIZE $MAX_RECORD_SIZE $MAX_BLOCK_SIZE >&! db_create-a.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-a.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set-a.out

if ($?gtm_test_replay) then
	@ sec_key_size = `echo $gtm_test_sec_key_size`
else
	@ sec_key_size = `$gtm_exe/mumps -run rand 27 1 5`
	echo "setenv gtm_test_sec_key_size $sec_key_size" >> settings.csh
endif

# Set default limits on the secondary instance
$MSR RUN INST2 '$gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT' '$sec_key_size' >&! db_create-a.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-a.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set-a.out'
echo

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Write a record that should work on both instances
$gtm_exe/mumps -direct >&! mumps-a1.out << EOF
set ^abc=12345
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Get the secondary's update process's id
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth' >&! checkhealth-a.out
set update_pid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth-a.out`

# Write a record that should cause KEY2BIG on the secondary
$gtm_exe/mumps -run oflowscndry >&! mumps-a2.out << EOF
1 $sec_key_size
EOF

# Wait for the update process on the secondary to die
$gtm_tst/com/wait_for_proc_to_die.csh $update_pid 120

# Now that the update process is down, we cannot use dbcheck.csh to stop processes; do it explicitly
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0; $MUPIP replic -source -shutdown -timeout=0' >&! sec_shut-a.out
$MSR STOP INST1
echo

# Verify that the databases are fine
$gtm_tst/com/dbcheck.csh -noshut
echo

# Prepare for the next case
set bak_dir = "dir-a"
$gtm_tst/com/backup_dbjnl.csh $bak_dir "*.dat *.mjl* *.gld" mv

# Ensure that the expected KEY2BIG was issued and also move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/check_error_exist.csh $update_log KEY2BIG; $gtm_tst/com/backup_dbjnl.csh '$bak_dir' "$update_log *dat *.mjl* *.gld" mv'
$gtm_tst/com/knownerror.csh $msr_execute_last_out KEY2BIG
echo

###################

$echoline

# To prevent cores on the secondary when dealing with keys too big, set the white-box test variables
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 23

# Set random limits on the primary instance
setenv gtm_test_sprgde_id "ID2_${RAND_REG_COUNT}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT $MAX_KEY_SIZE $MAX_RECORD_SIZE $MAX_BLOCK_SIZE >&! db_create-b.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-b.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set-b.out

# Set default limits on the secondary instance
$MSR RUN INST2 '$gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT' >&! db_create-b.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-b.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set-b.out'
echo

# Find out what the defaults are on the secondary instance
$MSR RUN INST2 '$DSE dump -f >&! dsedump.txt; cat dsedump.txt |& $grep "Maximum key size"' >&! dsedump-b.out
@ sec_key_size = `cat dsedump-b.out | $tail -1 | $tst_awk '{print $4}'`

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Write a record that should work on both instances
$gtm_exe/mumps -direct >&! mumps-b1.out << EOF
set ^abc=12345
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Get the secondary's update process's id
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth' >&! checkhealth-b.out
set update_pid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth-b.out`

# Write a record that should cause GVSUBOFLOW on the secondary
$gtm_exe/mumps -run oflowscndry >&! mumps-b2.out << EOF
2 $sec_key_size
EOF

# Wait for the update process on the secondary to die
$gtm_tst/com/wait_for_proc_to_die.csh $update_pid 120

# Now that the update process is down, we cannot use dbcheck.csh to stop processes; do it explicitly
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0; $MUPIP replic -source -shutdown -timeout=0' >&! sec_shut-b.out
$MSR STOP INST1
echo

# Verify that the databases are fine
$gtm_tst/com/dbcheck.csh -noshut
echo

# Prepare for the next case
set bak_dir = "dir-b"
$gtm_tst/com/backup_dbjnl.csh $bak_dir "*.dat *.mjl* *.gld" mv

# Ensure that the expected GVSUBOFLOW was issued and also move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/check_error_exist.csh $update_log GVSUBOFLOW; $gtm_tst/com/backup_dbjnl.csh '$bak_dir' "$update_log *dat *.mjl* *.gld" mv'
$gtm_tst/com/knownerror.csh $msr_execute_last_out GVSUBOFLOW
echo

###################

$echoline

# Set random limits on the primary instance
setenv gtm_test_sprgde_id "ID3_${RAND_REG_COUNT}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT $MAX_KEY_SIZE $MAX_RECORD_SIZE $MAX_BLOCK_SIZE >&! db_create-c.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-c.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set-c.out

# Set default limits on the secondary instance
$MSR RUN INST2 '$gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT' >&! db_create-c.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup-c.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set-c.out'
echo

# Find out what the defaults are on the secondary instance
$MSR RUN INST2 '$DSE dump -f >&! dsedump.txt; cat dsedump.txt |& $grep "Maximum record size"' >&! dsedump-c.out
@ sec_record_size = `cat dsedump-c.out | $tail -1 | $tst_awk '{print $4}'`

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Write a record that should work on both instances
$gtm_exe/mumps -direct >&! mumps-b1.out << EOF
set ^abc=12345
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Get the secondary's update process's id
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth' >&! checkhealth-c.out
set update_pid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth-c.out`

# Write a record that should cause GVSUBOFLOW on the secondary
$gtm_exe/mumps -run oflowscndry >&! mumps-c.out << EOF
3 $sec_record_size
EOF

# Wait for the update process on the secondary to die
$gtm_tst/com/wait_for_proc_to_die.csh $update_pid 120

# Now that the update process is down, we cannot use dbcheck.csh to stop processes; do it explicitly
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0; $MUPIP replic -source -shutdown -timeout=0' >&! sec_shut-c.out
$MSR RUN INST2 'set msr_dont_trace ; source $gtm_tst/com/portno_release.csh'
$MSR STOP INST1
echo

# Verify that the databases are fine
$gtm_tst/com/dbcheck.csh -noshut
echo

# Prepare for the next case
set bak_dir = "dir-c"
$gtm_tst/com/backup_dbjnl.csh $bak_dir "*.dat *.mjl* *.gld" mv

# Ensure that the expected REC2BIG was issued and also move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/check_error_exist.csh $update_log REC2BIG; $gtm_tst/com/backup_dbjnl.csh '$bak_dir' "$update_log *dat *.mjl* *.gld" mv'
$gtm_tst/com/knownerror.csh $msr_execute_last_out REC2BIG
echo
# Done using the white-box test
unsetenv gtm_white_box_test_case_enable
unsetenv gtm_white_box_test_case_number
