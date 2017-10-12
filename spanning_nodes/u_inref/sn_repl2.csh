#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# Create two instances with different maximum key sizes, source supporting larger keys. Write #
# records in increasing key size order until the secondary can no longer support them.        #
# Increase the key size limits and repeat.                                                    #
###############################################################################################
echo "Verify that replication instances can communicate properly so long as the key sizes of"
echo "updates written on the primary do not exceed the limit set on the secondary."
echo

# The test does most of the database/replication setup all by itself (by invoking dbcreate_base.csh). If $gtm_custom_errors
# is set, the MUPIP SET operations (done below) will try to open jnlpool and thus access mumps.repl which doesn't exist at
# this point thereby issuing FTOKERR/ENO2 errors. So, unsetenv gtm_custom_errors. While saving and restoring gtm_custom_errors
# is an option, this test does multiple dbcreates so saving and restoring for each dbcreate is an overkill. So, unsetenv the
# environment variable for the entire duration of the test.
unsetenv gtm_custom_errors

if ($?gtm_test_replay) then
	# Get previous limits
	@ i = 1
	while ($i <= 2)
		@ RAND_REG_COUNT_$i = `eval 'echo $gtm_test_rand_reg_count_'$i`
		@ RAND_RECORD_SIZE_$i = `eval 'echo $gtm_test_rand_record_size_'$i`
		@ RAND_BLOCK_SIZE_$i = `eval 'echo $gtm_test_rand_block_size_'$i`
		@ i = $i + 1
	end
	source $gtm_tst/com/set_limits.csh
else
	# Get random limits
	@ i = 1
	while ($i <= 2)
		source $gtm_tst/com/set_random_limits.csh
		@ RAND_REG_COUNT_$i = $RAND_REG_COUNT
		@ RAND_RECORD_SIZE_$i = $RAND_RECORD_SIZE
		@ RAND_BLOCK_SIZE_$i = $RAND_BLOCK_SIZE
		echo "setenv gtm_test_rand_reg_count_$i $RAND_REG_COUNT" >> settings.csh
		echo "setenv gtm_test_rand_record_size_$i $RAND_RECORD_SIZE" >> settings.csh
		echo "setenv gtm_test_rand_block_size_$i $RAND_BLOCK_SIZE" >> settings.csh
		@ i = $i + 1
	end
endif

# Prepare an MSR configuration with two instances, INST1 and INST2;
# INST1 is the root primary, and INST2 is the secondary.
$MULTISITE_REPLIC_PREPARE 2

# To prevent cores on the secondary when dealing with keys too big,
# set the white-box test variables
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 23

###################

$echoline
echo "Keys: 255 (INST1); $MIN_KEY_SIZE (INST2)"
$echoline
echo

# Set the maximum key size to be 255 on the primary instance
setenv gtm_test_sprgde_id "ID1_${RAND_REG_COUNT_1}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT_1 255 $RAND_RECORD_SIZE_1 $RAND_BLOCK_SIZE_1 >&! db_create1.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup1.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set1.out

# Use different gtm_test_sprgde_id for INST2 since it uses a separate dbcreate (than INST1).
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh"
set sprgdeset = "$sprgdeset; echo setenv gtm_test_sprgde_id ID2_${RAND_REG_COUNT_2} >> env_supplementary.csh"
$MSR RUN INST2 "set msr_dont_trace ; $sprgdeset "

# Set minimum possible maximum key size on the secondary instance
$MSR RUN INST2 'source $gtm_tst/com/set_limits.csh; $gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT_2' $MIN_KEY_SIZE $MAX_RECORD_SIZE $MIN_BLOCK_SIZE >&! db_create1.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup1.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set1.out'
echo

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Write a record on the primary fitting the minimum key size
$gtm_exe/mumps -direct >&! mumps11.out << EOF
set ^a="test1"
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Make sure that the record got transmitted
$MSR RUN INST2 '$gtm_dist/mumps -run %XCMD "write ^a,!"'
echo

# Get the secondary's update process's id
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth' >&! checkhealth1.out
set update_pid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth1.out`

# Write a record on the primary with the key exceeding the maximum size on the secondary
$gtm_exe/mumps -direct >&! mumps12.out << EOF
set ^abcdefg="test2"
EOF

# Wait for the update process on the secondary to die
$gtm_tst/com/wait_for_proc_to_die.csh $update_pid 120

# Kill the only global different across the instances, so that the extract diff succeeds
$gtm_exe/mumps -direct >&! mumps13.out << EOF
zkill ^abcdefg
EOF

# Now that the update process is down, we cannot use dbcheck.csh to stop processes; do it explicitly
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0; $MUPIP replic -source -shutdown -timeout=0' >&! sec_shut1.out
$MSR STOP INST1
echo

# Compare the extracts
$MSR EXTRACT ALL
echo

# Verify that the databases are fine
$gtm_tst/com/dbcheck.csh -noshut
echo

# Prepare for the next case
set dir1 = "key1"
$gtm_tst/com/backup_dbjnl.csh $dir1 "" mv

# Ensure that the expected GVSUBOFLOW was issued and also move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/check_error_exist.csh $update_log KEY2BIG; $gtm_tst/com/backup_dbjnl.csh '$dir1' "$update_log *dat *.mjl* *.gld" mv'
$gtm_tst/com/knownerror.csh $msr_execute_last_out KEY2BIG
echo

###################

$echoline
echo "Keys: $MAX_KEY_SIZE (INST1); 255 (INST2)"
$echoline
echo

# Set the largest-possible maximum key size on the primary instance
setenv gtm_test_sprgde_id "ID3_${RAND_REG_COUNT_1}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT_1 $MAX_KEY_SIZE $RAND_RECORD_SIZE_1 2048 >&! db_create2.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup2.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& mupip_set2.out

# Use different gtm_test_sprgde_id for INST2 since it uses a separate dbcreate (than INST1).
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh"
set sprgdeset = "$sprgdeset; echo setenv gtm_test_sprgde_id ID4_${RAND_REG_COUNT_2} >> env_supplementary.csh"
$MSR RUN INST2 "set msr_dont_trace ; $sprgdeset "

# Set the maximum key size to be 255 on the secondary
$MSR RUN INST2 'source $gtm_tst/com/set_limits.csh; $gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT_2' 255 $MAX_RECORD_SIZE $MIN_BLOCK_SIZE >&! db_create2.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup2.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set2.out'
echo

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Create a few long key names
set key1 = '^abcdefghijklmnopqrstuvwxyz'
set key2 = '^b("abc","bcd","cde","def","efg","fgh","ghi","hij","ijk","jkl","klm","lmn","mno","nop","opq","pqr","qrs","rst","stu","tuv","uvw","vwx","wxy","xyz")'
set key3 = "^abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
set key4 = "^abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz"
set key5 = "^abcdefghijklmnopqrstuvwxyz(123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890,123456789012345678901234567890)"
set key6 = '^a("bcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")'

# Write a record on the primary fitting the 255 key size
$gtm_exe/mumps -direct >&! mumps21.out << EOF
set $key1="test1"
set $key2="test2"
set $key3="test3"
set $key4="test4"
set $key5="test5"
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Prepare the script to check whether the records got transmitted
cat << EOF >&! check1.m
check1
  if $key1'="test1" write "TEST-E-FAIL The value of $key1 is different",!
  if $key2'="test2" write "TEST-E-FAIL The value of ^a(""abc"",""bcd"",...) is different",!
  if $key3'="test4" write "TEST-E-FAIL The value of $key3 is different",!
  if $key4'="test4" write "TEST-E-FAIL The value of $key4 is different",!
  if $key5'="test5" write "TEST-E-FAIL The value of $key5 is different",!
  quit
EOF

# Make sure that the records got transmitted
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/check1.m _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 '$gtm_dist/mumps -run check1'
echo

# Get the secondary's update process's id
$MSR RUN INST2 '$MUPIP replic -receiver -checkhealth' >&! checkhealth2.out
set update_pid = `$tst_awk '/PID.*Update process/{print $2}' checkhealth2.out`

# Write a record on the primary with the key exceeding the maximum size on the secondary
$gtm_exe/mumps -direct >&! mumps22.out << EOF
set $key6="test6"
EOF

# Wait for the update process on the secondary to die
$gtm_tst/com/wait_for_proc_to_die.csh $update_pid 120

# Kill the only global different across the instances, so that the extract diff succeeds
$gtm_exe/mumps -direct >&! mumps23.out << EOF
zkill $key6
EOF

# Now that the update process is down, we cannot use dbcheck.csh to stop processes; do it explicitly
$MSR RUN INST2 '$MUPIP replic -receiv -shutdown -timeout=0; $MUPIP replic -source -shutdown -timeout=0' >&! sec_shut2.out
$MSR STOP INST1
echo

# Compare the extracts
$MSR EXTRACT ALL
echo

# Verify that the databases are fine
$gtm_tst/com/dbcheck.csh -noshut
echo

# Prepare for the next case
set dir2 = "key2"
$gtm_tst/com/backup_dbjnl.csh $dir2 "" mv

# Ensure that the expected GVSUBOFLOW was issued and also
# move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/check_error_exist.csh $update_log GVSUBOFLOW; $gtm_tst/com/backup_dbjnl.csh '$dir2' "$update_log *dat *.mjl* *.gld" mv'
$gtm_tst/com/knownerror.csh $msr_execute_last_out GVSUBOFLOW
echo

###################

$echoline
echo "Keys: $MAX_KEY_SIZE (INST1); $MAX_KEY_SIZE (INST2)"
$echoline
echo

# Set the largest-possible maximum key size on the primary instance
setenv gtm_test_sprgde_id "ID5_${RAND_REG_COUNT_1}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT_1 $MAX_KEY_SIZE 2000 4096 >&! db_create3.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup3.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >>& mupip_set3.out

# Use different gtm_test_sprgde_id for INST2 since it uses a separate dbcreate (than INST1).
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh"
set sprgdeset = "$sprgdeset; echo setenv gtm_test_sprgde_id ID6_${RAND_REG_COUNT_2} >> env_supplementary.csh"
$MSR RUN INST2 "set msr_dont_trace ; $sprgdeset "

# Set the largest-possible maximum key size on the secondary as well
$MSR RUN INST2 'source $gtm_tst/com/set_limits.csh; $gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT_2' $MAX_KEY_SIZE $MAX_RECORD_SIZE 1500 >&! db_create3.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup3.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set3.out'
echo

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Create a few very long key names
set key1 = '^a("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyz")'
set long_subscript = '("abcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxyzabcdefghijklmnopqrstuvwxy")'
set key2 = '^b'$long_subscript
set key3 = '^c'$long_subscript

# Write a record on the primary fitting the key size
$gtm_exe/mumps -direct >&! mumps31.out << EOF
set $key1="test1"
set $key2="test2"
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Prepare the script to check whether the records got transmitted
cat << EOF >&! check2.m
check2
  if $key1'="test1" write "TEST-E-FAIL The value of ^a(abcde...) is different",!
  if $key2'="test2" write "TEST-E-FAIL The value of ^b(abcde...) is different",!
  quit
EOF

# Make sure that the records got transmitted
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/check2.m _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 '$gtm_dist/mumps -run check2'
echo

# Write a record that will not span on the primary, but will on the secondary,
# thus producing a key that uses four more bytes
$gtm_exe/mumps -direct >&! mumps32.out << EOF
set $key3=\$justify("test3",1800)
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Prepare the script to check whether the records got transmitted
cat << EOF >&! check3.m
check3
  if $key3'=\$justify("test3",1800) write "TEST-E-FAIL The value of ^c(abcde...) is different",!
  quit
EOF

# Make sure that the records got transmitted
$MSR RUN SRC=INST1 RCV=INST2 '$gtm_tst/com/cp_remote_file.csh __SRC_DIR__/check3.m _REMOTEINFO___RCV_DIR__/'
$MSR RUN INST2 '$gtm_dist/mumps -run check3'
echo

# Shut down the replication and verify that the databases are fine
$gtm_tst/com/dbcheck.csh -extract
echo

# Move certain things case-specific directory for consistency
set dir3 = "key3"
$gtm_tst/com/backup_dbjnl.csh $dir3 "" mv

# Move things out of the way on secondary
$MSR RUN INST2 'set update_log = `ls RCVR_*.updproc`; $gtm_tst/com/backup_dbjnl.csh '$dir3' "$update_log *dat *.mjl* *.gld" mv'
