#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2012, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

###############################################################################################
# This script is used as a part of spanning_nodes/sn_repl4 test to create two instances with  #
# identical, but random, configurations, and ensure that replication works properly, by       #
# writing about 10 MB of updates to the database.                                             #
###############################################################################################

# The test does most of the database/replication setup all by itself (by invoking dbcreate_base.csh). If $gtm_custom_errors
# is set, the MUPIP SET operations (done below) will try to open jnlpool and thus access mumps.repl which doesn't exist at
# this point thereby issuing FTOKERR/ENO2 errors. So, unsetenv gtm_custom_errors unless we are at a point where the source
# servers are about to be started.
if ($?gtm_custom_errors) then
	setenv restore_gtm_custom_errors $gtm_custom_errors
	unsetenv gtm_custom_errors
endif

# Get the current index for naming purposes
set index = $1

if ($?gtm_test_replay) then
	# Get previous limits
	@ RAND_REG_COUNT = `eval 'echo $gtm_test_rand_reg_count_'$index`
	@ RAND_KEY_SIZE = `eval 'echo $gtm_test_rand_key_size_'$index`
	@ RAND_RECORD_SIZE = `eval 'echo $gtm_test_rand_record_size_'$index`
	@ RAND_BLOCK_SIZE = `eval 'echo $gtm_test_rand_block_size_'$index`
	@ RAND_GLOBAL_BUFFER_COUNT = `eval 'echo $gtm_test_rand_global_buffer_count_'$index`
	source $gtm_tst/com/set_limits.csh
else
	# Get random limits, but such that would prevent the overflow of the global we use for logging of the generated keys
	# and values, as follows from the longest string it will contain:
	#   '^' + key + '="...' + value + '"' = 7 characters + length of the key + length of the value (at most 26 chars)
	source $gtm_tst/com/set_random_limits.csh
	set max_generated_value_len = $RAND_RECORD_SIZE
	if (26 < $max_generated_value_len) set max_generated_value_len = 26
	while (($RAND_RECORD_SIZE - $RAND_KEY_SIZE - $max_generated_value_len) < 7)
		source $gtm_tst/com/set_random_limits.csh
		set max_generated_value_len = $RAND_RECORD_SIZE
		if (26 < $max_generated_value_len) set max_generated_value_len = 26
	end
	echo "setenv gtm_test_rand_reg_count_$index $RAND_REG_COUNT" >> settings.csh
	echo "setenv gtm_test_rand_key_size_$index $RAND_KEY_SIZE" >> settings.csh
	echo "setenv gtm_test_rand_record_size_$index $RAND_RECORD_SIZE" >> settings.csh
	echo "setenv gtm_test_rand_block_size_$index $RAND_BLOCK_SIZE" >> settings.csh
	echo "setenv gtm_test_rand_global_buffer_count_$index $RAND_GLOBAL_BUFFER_COUNT" >> settings.csh
endif


# Prepare an MSR configuration with two instances, INST1 and INST2;
# INST1 is the root primary, and INST2 is the secondary
$MULTISITE_REPLIC_PREPARE 2

# Ensure the key size of 11, so that ^gbl(index) in fill.m would always fit
if ($RAND_KEY_SIZE < 11) @ RAND_KEY_SIZE = 11

# Set random limits on the primary instance
setenv gtm_test_sprgde_id "ID_${index}_${RAND_REG_COUNT}"	# to differentiate multiple dbcreates (in rand_repl.csh) done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT $RAND_KEY_SIZE $RAND_RECORD_SIZE $RAND_BLOCK_SIZE . $RAND_GLOBAL_BUFFER_COUNT >&! db_create${index}.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup${index}.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set${index}.out

# Set same limits on the secondary instance
$MSR RUN INST2 '$gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT' '$RAND_KEY_SIZE' '$RAND_RECORD_SIZE' '$RAND_BLOCK_SIZE' . '$RAND_GLOBAL_BUFFER_COUNT' >&! db_create'${index}'.outx; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup'${index}'.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set'${index}'.out'
echo

# Restore gtm_custom_errors
if ($?restore_gtm_custom_errors) then
	setenv gtm_custom_errors $restore_gtm_custom_errors
	unsetenv restore_gtm_custom_errors
endif

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Write records on the primary until we have saved 10 MB worth of data
$gtm_exe/mumps -run fill >&! mumps${index}.out << EOF
$MIN_KEY_SIZE $RAND_KEY_SIZE $MIN_RECORD_SIZE $RAND_RECORD_SIZE 10485760
EOF

# Sync the updates between INST1 and INST2
$MSR SYNC INST1 INST2
echo

# Shut down the replication and verify that the databases are fine
$gtm_tst/com/dbcheck.csh -extract
echo

# Prepare for the next case
set bak_dir = "dir${index}"
$gtm_tst/com/backup_dbjnl.csh $bak_dir "*.dat *.mjl* *.gld" mv
# Also move things out of the way on the secondary
$MSR RUN INST2 "set msr_dont_trace ; $gtm_tst/com/backup_dbjnl.csh $bak_dir "'"*.dat *.mjl* *.gld"'" mv"
echo
