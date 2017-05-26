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
# Create three instances with different region count, key size, record size, and block size   #
# configurations. Then write several updates per region, each update involving a global with  #
# different key length, with or without subscripts. Finally, make sure that all updated have  #
# been propagated properly to the remote instances.                                           #
###############################################################################################
echo "Verify that three instances, of which one will span, one can span, and one will not span, "
echo "will receive updates correctly through replication channels."
echo

# The test does most of the database/replication setup all by itself (by invoking dbcreate_base.csh). If $gtm_custom_errors
# is set, the MUPIP SET operations (done below) will try to open jnlpool and thus access mumps.repl which doesn't exist at
# this point thereby issuing FTOKERR/ENO2 errors. So, unsetenv gtm_custom_errors unless we are at a point where the source
# servers are about to be started.
if ($?gtm_custom_errors) then
	setenv restore_gtm_custom_errors $gtm_custom_errors
	unsetenv gtm_custom_errors
endif

if ($?gtm_test_replay) then
	# Get previous limits
	@ i = 1
	while ($i <= 3)
		@ RAND_REG_COUNT_$i = `eval 'echo $gtm_test_rand_reg_count_'$i`
		@ RAND_BLOCK_SIZE_$i = `eval 'echo $gtm_test_rand_block_size_'$i`
		@ i = $i + 1
	end
	source $gtm_tst/com/set_limits.csh
else
	# Get random limits
	@ i = 1
	while ($i <= 3)
		source $gtm_tst/com/set_random_limits.csh
		@ RAND_REG_COUNT_$i = $RAND_REG_COUNT
		@ RAND_BLOCK_SIZE_$i = $RAND_BLOCK_SIZE
		echo "setenv gtm_test_rand_reg_count_$i $RAND_REG_COUNT" >> settings.csh
		echo "setenv gtm_test_rand_block_size_$i $RAND_BLOCK_SIZE" >> settings.csh
		@ i = $i + 1
	end
endif

# Define the max size of a global we will write
@ MAX_GLOBAL_SIZE = $MAX_BLOCK_SIZE - 50

# Prepare an MSR configuration with three instances, INST1, INST2, and INST3;
# INST1 is the root primary, and INST2 and INST3 are secondaries.
$MULTISITE_REPLIC_PREPARE 3

# Create the database on the primary with random-sized blocks that can hold records of the maximum size;
# nodes on this instance CAN span
setenv gtm_test_sprgde_id "ID1_${RAND_REG_COUNT_1}"	# to differentiate multiple dbcreates done in the same subtest
$gtm_tst/com/dbcreate_base.csh mumps $RAND_REG_COUNT_1 28 $MAX_RECORD_SIZE $RAND_BLOCK_SIZE_1 >&! db_create.outx
$grep MUNOSTRMBKUP dbcreate.out >&! /dev/null
if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup.outx
$MUPIP set -replication=on $tst_jnl_str -REG "*" >&! mupip_set.out

# Use different gtm_test_sprgde_id for INST2 since it uses a separate dbcreate (than INST1).
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh"
set sprgdeset = "$sprgdeset; echo setenv gtm_test_sprgde_id ID2_${RAND_REG_COUNT_2} >> env_supplementary.csh"
$MSR RUN INST2 "set msr_dont_trace ; $sprgdeset "

# Create the database on the first secondary with minimum-sized blocks that can hold records of the maximum size;
# nodes on this instance WILL span
$MSR RUN INST2 'source $gtm_tst/com/set_limits.csh ; $gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT_2' 255 $MAX_RECORD_SIZE $MIN_BLOCK_SIZE >&! db_create.outx ; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup.outx'
$MSR RUN INST2 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set.out'
echo

# Use different gtm_test_sprgde_id for INST3 since it uses a separate dbcreate (than INST1).
set sprgdeset = "echo setenv gtm_test_sec_sprgde_id_different 1 >> env_supplementary.csh"
set sprgdeset = "$sprgdeset; echo setenv gtm_test_sprgde_id ID3_${RAND_REG_COUNT_3} >> env_supplementary.csh"
$MSR RUN INST3 "set msr_dont_trace ; $sprgdeset "

# Create the database on the second secondary with maximum-sized blocks that can hold records of comparable size;
# nodes on this instance WILL NOT span
$MSR RUN INST3 'source $gtm_tst/com/set_limits.csh ; $gtm_tst/com/dbcreate_base.csh mumps '$RAND_REG_COUNT_3' $MAX_KEY_SIZE '$MAX_GLOBAL_SIZE' $MAX_BLOCK_SIZE >&! db_create.outx ; $grep MUNOSTRMBKUP dbcreate.out >&! /dev/null; if (! $status) $gtm_tst/com/check_error_exist.csh dbcreate.out MUNOSTRMBKUP >&! munostrmbkup.outx'
$MSR RUN INST3 '$MUPIP set -replication=on '$tst_jnl_str' -REG "*" >&! mupip_set.out'
echo

# Restore gtm_custom_errors
if ($?restore_gtm_custom_errors) then
	setenv gtm_custom_errors $restore_gtm_custom_errors
	unsetenv restore_gtm_custom_errors
endif

# Start replication between INST1 and INST2
$MSR START INST1 INST2 RP
echo

# Start replication between INST1 and INST3
$MSR START INST1 INST3 RP
echo

# Prepare the script to initialize a number of region-bound globals
cat << EOF >&! setup.m
setup
  for i=0:1:25 do
  . set base="^"_\$char(97+i)
  . set full=base_"(4,3,2,1)"
  . for j=5:-1:1 do
  . . set name=\$extract(full,1,2*j)
  . . if (j'=1) set name=name_")"
  . . set @name=-1
  quit
EOF

# Launch a GT.M process to set up the globals
$gtm_exe/mumps -run setup >&! mumps.out

# Prepare an M script to write a few updates to the primary
cat << EOF >&! updates.m
updates
  for i=0:1:25 do
  . set base="^"_\$char(97+i)
  . set full=base_"(4,3,2,1)"
  . set randoms=""
  . for j=5:-1:1 do
  . . set r=\$random($MAX_GLOBAL_SIZE)
  . . set randoms=randoms_r
  . . set name=\$extract(full,1,2*j)
  . . if (j'=1) set name=name_")",randoms=randoms_" "
  . . set @name=\$justify("abcdefghijklmnopqrstuvwxyz",r)
  . zsystem "echo "_randoms_" >> updates.outx"
  quit
EOF

# Launch a GT.M process to overwrite existing globals on the primary
$gtm_exe/mumps -run updates >&! mumps2.out

# Shut down the replication and verify that the databases are fine
$gtm_tst/com/dbcheck.csh -extract
