#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test online (re)encryption on a prefilled database:
#
#   a) From unencrypted to encrypted to encrypted with different keys.
#   b) From encrypted to encrypted with different keys.
#
#   This test additionally covers the following aspects:
#
#   - All operations may be done on up to five regions.
#   - One region may be referenced by multiple names.
#   - Verify that a process may start before the (re)encryption begins or after the first pass has completed.
#   - Multiple (re)encryptions are peformed back-to-back.
#   - After (re)encryption completes, all concurrent MUMPS processes are able to use the database.

unsetenv gtmdbglvl	# or else test runs for too long (close to an hour)
echo '# test takes too long to run with non-zero gtmdbglvl' >>&! settings.csh
echo 'unsetenv gtmdbglvl' >>&! settings.csh

# Encryption cannot work on V4 databases.
setenv gtm_test_mupip_set_version "disable"

@ num_of_reorg_cycles = 10
@ process_count = 5

if (! $?gtm_test_replay) then
	# Choose the number of database regions.
	@ reg_count = `$gtm_dist/mumps -run rand 5 1 1`
	echo "setenv reg_count $reg_count" >> settings.csh

	# Choose whether we start with an unencrypted database.
	@ unencrypted = `$gtm_dist/mumps -run rand 2 1 0`
	echo "setenv unencrypted $unencrypted" >> settings.csh

	# Choose the maximum record size.
	@ max_record_size = `$gtm_dist/mumps -run %XCMD 'write 2**($random(5)+8)'`
	echo "setenv max_record_size $max_record_size" >> settings.csh
endif

if ($unencrypted) then
	setenv test_encryption NON_ENCRYPT
endif

echo "Create a database."
setenv gtm_test_sprgde_id "ID1_${reg_count}"
$gtm_tst/com/dbcreate.csh mumps $reg_count . $max_record_size >&! db_create_log.out

set key_base = "key"
set dbkeys_base = "db_mapping_file"
set dats = `$gtm_dist/mumps -run %XCMD 'set reg="" for  set reg=$view("gvnext",reg) quit:(""=reg)  set dat=$view("gvfile",reg),dat=$piece(dat,"/",$length(dat,"/")) write dat_" "'`
set gtm_dbkeys_common = "${dbkeys_base}.both"

# If we started with an unencrypted database, set necessary variables for future encryption and make all regions encryptable.
if ($unencrypted) then
	setenv gtmcrypt_config gtmcrypt.cfg
	setenv gtm_dbkeys $dbkeys_base
	setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	touch $gtm_dbkeys

	$MUPIP set -encryptable -region "*" >&! mupip_set_encryptable.out
	@ encryptable_count = `$grep -c "now has encryptable flag set to  TRUE" mupip_set_encryptable.out`
	if ($reg_count != $encryptable_count) then
		echo "TEST-E-FAIL, Not all regions have been set encryptable"
		exit 1
	endif
endif

# Prefill the database
echo
echo "Prefill the database."
$gtm_dist/mumps -run filler fill.m 60000 $max_record_size 0
$gtm_dist/mumps -run fill

# Pregenerate all keys and configurations.
echo
echo "Pregenerate keys and configurations."
@ iteration = $num_of_reorg_cycles
while ($iteration >= 1)
	setenv gtm_encrypt_notty "--no-permission-warning"
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 ${key_base}${iteration}
	unsetenv gtm_encrypt_notty

	foreach dat ($dats)
		echo "dat $dat" >> $gtm_dbkeys
		echo "key ${key_base}${iteration}" >> $gtm_dbkeys
	end

	@ iteration--
end
$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys $gtmcrypt_config

# Optionally set journaling.
@ use_journaling = `$gtm_dist/mumps -run rand 2 1 0`
if ($use_journaling) then
	$MUPIP set "$tst_jnl_str" -reg "*" >&! mupip_set_journal.out
endif

# Start concurrent writers.
$gtm_dist/mumps -run start^concur $process_count

echo
echo "Start reencryption cycle."
@ iteration = 1
while ($iteration <= $num_of_reorg_cycles)
	# Start MUPIP REORG -ENCRYPT in the background.
	($MUPIP reorg -encrypt=${key_base}${iteration} -region "*" >>&! mupip_reorg_encrypt${iteration}.out &; echo $! > mre_pid${iteration}) >&! /dev/null
	@ pid = `cat mre_pid${iteration}`

	# Unless we run out of concurrent writers, keep checking the load and stopping them one by one every thirty seconds.
	@ reorg_finished = 0
	while (0 <= $process_count)
		@ timer = 0
		while (30 > $timer)
			@ reorg_finished = `$gtm_tst/com/is_proc_alive.csh $pid; echo $status` # ` for vim highlighting
			if ($reorg_finished) break
			@ timer++
			sleep 1
		end
		if ($reorg_finished) break
		$gtm_dist/mumps -run stopone^concur
		@ process_count--
	end

	# If the reorg process terminated, verify that it completed the job.
	if ($reorg_finished) then
		@ reorg_count = `$grep -c "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt${iteration}.out`
		if ($reg_count != $reorg_count) then
			echo "TEST-E-FAIL, Unexpected status of MUPIP REORG -ENCRYPT operation. See mupip_reorg_encrypt${iteration}.out for details"
			$gtm_dist/mumps -run stopall^concur
			exit 1
		endif

		# Mark the encryption complete.
		$MUPIP set -encryptioncomplete -region "*" >&! mupip_set_encryption_complete${iteration}.out
		@ complete_count = `$grep -c "encryption marked complete" mupip_set_encryption_complete${iteration}.out`
		if ($reg_count != $complete_count) then
			echo "TEST-E-FAIL, Unexpected status of MUPIP SET -ENCRYPTIONCOMPLETE operation. See mupip_set_encryption_complete${iteration}.out for details"
			$gtm_dist/mumps -run stopall^concur
			exit 1
		endif
	else
		echo "TEST-E-FAIL, Timed out waiting for MUPIP REORG ENCRYPT to finish"
		$gtm_dist/mumps -run stopall^concur
		exit 1
	endif

	@ iteration++
end

# Terminate all writers.
$gtm_dist/mumps -run stopall^concur

echo
$gtm_tst/com/dbcheck.csh
