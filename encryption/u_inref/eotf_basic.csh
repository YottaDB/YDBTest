#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test basic stand-alone (re)encryption functionality:
#
#   a) From unencrypted to encrypted.
#   b) From encrypted with one key to encrypted with a different key.
#
#   This test additionally performs the following:
#
#   - Encrypting an encrypted database without first supplying the -encryptable flag should not work.
#   - Ensure that MUPIP CREATE uses the last entry.
#   - Notify if already encrypted with the requested key.
#   - Encrypted databases continue to work with the configuration file containing either both new and old keys or just the new ones.
#   - Regions are randomized to be either particular ones (but not necessarily all) or "*"; only the chosen regions should be verified for encryption status.
#   - Path to the key is specified either in absolute or relative fashion, randomly.
#   - Optionally uses journaling.
#   - When journaling, verifies that two journal file switches occur.
#   - Checks that MUREENCRYPTEND is printed in the syslog when (re)encryption is complete.
#   - Databases initially using null IV switch to non-null IV after reencryption.

# Encryption cannot work on V4 databases.
setenv gtm_test_mupip_set_version "disable"

if (! $?gtm_test_replay) then
	# Choose the number of regions.
	@ REG_COUNT = `$gtm_dist/mumps -run rand 5 1 1`
	echo "setenv REG_COUNT $REG_COUNT" >> settings.csh

	set random_options = `$gtm_dist/mumps -run rand 2 4 0`

	# Optionally set journaling.
	@ use_journaling = $random_options[1]
	echo "setenv use_journaling $use_journaling" >> settings.csh

	# Choose whether to use NULL IVs.
	# But in a YDB environment, running pre-V63000A versions with encryption results in CRYPTKEYFETCHFAILED (hash mismatch)
	# so do not use null iv that way the test does not choose those random versions.
	# @ use_null_iv = $random_options[2]
	@ use_null_iv = 0
	echo "setenv use_null_iv $use_null_iv" >> settings.csh

	if ($use_null_iv) then
		# Pick a random prior version for the first case.
		set prior_ver1 = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
		if ("$prior_ver1" =~ "*-E-*") then
			echo "No prior versions available: $prior_ver1"
			exit 1
		endif
		echo "setenv prior_ver1 $prior_ver1" >> settings.csh
		source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver1

		# Pick a random prior version for the second case.
		set prior_ver2 = `$gtm_tst/com/random_ver.csh -lte V62002 -gte V53004`
		if ("$prior_ver2" =~ "*-E-*") then
			echo "No prior versions available: $prior_ver2"
			exit 1
		endif
		echo "setenv prior_ver2 $prior_ver2" >> settings.csh
		source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver2
	endif

	# Optionally make the database encryptable in the first case.
	@ set_encryptable1 = $random_options[3]
	echo "setenv set_encryptable1 $set_encryptable1" >> settings.csh

	# Optionally make the database encryptable in the second case.
	@ set_encryptable2 = $random_options[4]
	echo "setenv set_encryptable2 $set_encryptable2" >> settings.csh
endif

set data_creation = 'set beg=$ascii("a") for i=beg:1:beg+'$REG_COUNT'-1 set var="^"_$char(i) set @var=(i-beg+1)'
set data_verification = 'set beg=$ascii("a") for i=beg:1:beg+'$REG_COUNT'-1 set var="^"_$char(i) write:($select(@var=(i-beg+1):0,1:1)) "TEST-E-FAIL, Bad value for "_var,!'

# First, the encrypted case (to get keys created).
echo "Case 1. Reencrypting an encrypted database."

echo
echo "Creating a database."

if ($use_journaling) then
	setenv gtm_test_jnl SETJNL
endif

# Since this test switches to an older version (using "switch_gtm_version.csh"), we should disable use of V6 version in
# `dbcreate.csh` as it would otherwise get confusing. This is because the `dbcreate.csh` should happen using the prior
# version but would otherwise happen with the randomly chosen version in the env var `gtm_test_v6_dbcreate_rand_ver`.
setenv gtm_test_use_V6_DBs 0

setenv gtm_test_sprgde_id "ID1_${REG_COUNT}"	# to differentiate multiple dbcreates done in the same subtest
if ($use_null_iv) then
	# Choose a random prior version that supports encryption but uses null IVs.
	echo "$prior_ver1" > priorver.out
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver1 $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh

	# Create a database using the old version.
	$gtm_tst/com/dbcreate.csh mumps $REG_COUNT >&! dbcreate_priorver.out

	# Switch back to the current version.
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	$GDE exit >&! gde.out
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	endif
else
	$gtm_tst/com/dbcreate.csh mumps $REG_COUNT >&! db_create_log.out
endif

# Do an update with a different value on each region.
$gtm_dist/mumps -run %XCMD "$data_creation"

# Set up the list of region names as well as an all-region value.
if (! $?gtm_test_replay) then
	set REG_LIST = `$gtm_dist/mumps -run %XCMD 'set (regs,reg)="" for  set reg=$view("gvnext",reg) set regs=$select(""=regs:reg,""=reg:regs,1:regs_","_reg) if (""=reg) write regs quit'`
	@ use_reg_list = `$gtm_dist/mumps -run rand 2 1 0`
	if ($use_reg_list) then
		set REG_ARG = $REG_LIST
	else
		set REG_ARG = "*"
	endif
	echo 'setenv REG_ARG "'"$REG_ARG"'"' >> settings.csh
endif

# Prepare the extra keys.
setenv gtm_encrypt_notty "--no-permission-warning"
set keys = `$tst_awk -F '/' '/key / {print $NF}' $gtm_dbkeys`
foreach key ($keys)
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 ${key}2
end
unsetenv gtm_encrypt_notty

# Add the extra keys to the encryption configuration.
set gtmcrypt_config_base = $gtmcrypt_config
mv $gtmcrypt_config_base ${gtmcrypt_config_base}.orig
$tst_awk '/key / {print $0"2"} /dat / {print}' $gtm_dbkeys > ${gtm_dbkeys}.bak
cp $gtm_dbkeys ${gtm_dbkeys}.orig
cat ${gtm_dbkeys}.bak >> $gtm_dbkeys
setenv gtmcrypt_config ${gtmcrypt_config}.both
$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys $gtmcrypt_config

# Optionally make the regions encryptable.
echo
echo "Setting regions encryptable ($set_encryptable1)."
if ($set_encryptable1) then
	$MUPIP set -encryptable -region "$REG_ARG" >&! mupip_set_encryptable.out
	@ encryptable_count = `$grep -c "now has encryptable flag set to  TRUE" mupip_set_encryptable.out`
	if ($REG_COUNT != $encryptable_count) then
		echo "TEST-E-FAIL, Not all regions have been set encryptable"
		exit 1
	endif
endif

# Reencrypt every region with either the same or a different key.
echo
echo "(Re)encrypt regions."
set datkey_pairs = `$tst_awk -F '/' 'NR%2{printf $NF" ";next} {print $NF}' ${gtm_dbkeys}.orig`
@ datkey_pairs_count = $#datkey_pairs
@ i = 1
while ($i <= $datkey_pairs_count)
	# Save the database and region names for later use.
	set dat = $datkey_pairs[$i]
	set reg = `$gtm_dist/mumps -run %XCMD 'set reg="" for  set reg=$view("gvnext",reg) quit:(""=reg)  set dat=$view("gvfile",reg),dat=$piece(dat,"/",$length(dat,"/")) write:(dat="'$dat'") reg'`
	@ i++
	set key = $datkey_pairs[$i]

	if (! $?gtm_test_replay) then
		@ use_existing_key = `$gtm_dist/mumps -run rand 2 1 0`
		echo "setenv use_existing_key_$i $use_existing_key" >> settings.csh
	else
		set var = '$use_existing_key_'$i
		eval "@ use_existing_key = $var"
	endif
	if (! $use_existing_key) then
		set key = ${key}2
	endif

	if (! $?gtm_test_replay) then
		@ use_absolute_path = `$gtm_dist/mumps -run rand 2 1 0`
		echo "setenv use_absolute_path_1_$i $use_absolute_path" >> settings.csh
	else
		set var = '$use_absolute_path_1_'$i
		eval "@ use_absolute_path = $var"
	endif
	if ($use_absolute_path) then
		set key = `pwd`/${key}
	endif

	echo "dat $dat" >> ${gtm_dbkeys}.new
	echo "key $key" >> ${gtm_dbkeys}.new

	# Do MUPIP REORG -ENCRYPT.
	set syslog_time_before = `date +"%b %e %H:%M:%S"`
	$MUPIP reorg -encrypt=$key -region $reg >>&! mupip_reorg_encrypt.out
	set syslog_time_after = `date +"%b %e %H:%M:%S"`

	# Depending on whether we are reencrypting with the same key, set expectations accordingly.
	if ($use_existing_key) then
		set grep_str = "Region $reg : Data already encrypted with the desired key"
	else
		set grep_str = "Region $reg : MUPIP REORG ENCRYPT finished"
	endif

	$grep -q "$grep_str" mupip_reorg_encrypt.out
	if ($status) then
		echo "TEST-E-FAIL, Unexpected status of MUPIP REORG -ENCRYPT operation. See mupip_reorg_encrypt.out for details"
		exit 1
	endif

	# If we are encrypting with a new key, expect a few more things to happen.
	if (! $use_existing_key) then
		set syslogfile = "syslog_case1_${i}.txt"
		$gtm_tst/com/getoper.csh "$syslog_time_before" "$syslog_time_after" $syslogfile "" "MUREENCRYPTEND, Database $cwd/$dat : MUPIP REORG ENCRYPT finished"

		# In case of journaling, expect two journal switches.
		if ($use_journaling) then
			set mjl = ${dat:s/dat/mjl/}
			@ jnl_switch_count = `$grep -cE "NEWJNLFILECREAT.*$cwd/${mjl}" $syslogfile`
			if (2 != $jnl_switch_count) then
				echo "TEST-E-FAIL, MUPIP REORG -ENCRYPT caused $jnl_switch_count journal switch(es) instead of 2. See $syslogfile for details"
				exit 1
			endif
		endif
	endif

	# Expect the appropriate IV status.
	$gtm_tst/com/dse_command.csh -region $reg -do 'dump -file -all'
	set null_iv = `cat dse_commands.out |& $tst_awk '/null IV/ {print $7}'`
	mv dse_commands.out dse_dump_${reg}.out
	if (((! $use_existing_key) && ("TRUE" == $null_iv)) || ($use_existing_key && $use_null_iv && ("FALSE" == $null_iv))) then
		echo "TEST-E-FAIL, On region $reg after MUPIP REORG -ENCRYPT the database null IV status is $null_iv"
		exit 1
	endif
	@ i++
end

# Verify that everything could be decrypted with a combination of the old and new keys.
echo
echo "Verify decryption with old and new keys."
$gtm_dist/mumps -run %XCMD "$data_verification"

# Verify that everything could be decrypted using only the new keys.
echo
echo "Verify decryption with new keys only."
setenv gtmcrypt_config ${gtmcrypt_config_base}.new
$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.new $gtmcrypt_config
$gtm_dist/mumps -run %XCMD "$data_verification"

# Validate and back up.
echo
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.gld *.out *.cfg *.mjl*" mv nozip
$gtm_tst/com/backup_dbjnl.csh bak1 "*.bak *.orig *.new" cp nozip

# Then the non-encrypted case.
echo
echo "Case 2. Encrypting an unencrypted database."

# Create databases and do an update with a different value on each.
echo
echo "Creating a database."
setenv test_encryption NON_ENCRYPT
setenv gtm_test_sprgde_id "ID2_${REG_COUNT}"	# to differentiate multiple dbcreates done in the same subtest
if ($use_null_iv) then
	# Choose a random prior version that supports encryption but uses null IVs.
	echo "$prior_ver2" > priorver.out
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver2 $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh

	# Create a database using the old version.
	$gtm_tst/com/dbcreate.csh mumps $REG_COUNT >&! dbcreate_priorver.out

	# Switch back to the current version.
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	$GDE exit >&! gde.out
	if (-f $gtm_dbkeys) then
		$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys gtmcrypt.cfg
	endif
else
	$gtm_tst/com/dbcreate.csh mumps $REG_COUNT >&! db_create_log.out
endif
$gtm_dist/mumps -run %XCMD "$data_creation"

# Prepare the encryption configuration (environment should still be set).
setenv gtmcrypt_config $gtmcrypt_config_base
$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys.bak $gtmcrypt_config

# Optionally make the regions encryptable.
echo
echo "Setting regions encryptable ($set_encryptable2)."
if ($set_encryptable2) then
	$MUPIP set -encryptable -region "$REG_ARG" >&! mupip_set_encryptable.out
	@ encryptable_count = `$grep -c "now has encryptable flag set to  TRUE" mupip_set_encryptable.out`
	if ($REG_COUNT != $encryptable_count) then
		echo "TEST-E-FAIL, Not all regions have been set encryptable"
		exit 1
	endif
endif

# Attempt to encrypt every region.
echo
echo "Encrypt regions."
rm ${gtm_dbkeys}.new
set datkey_pairs = `$tst_awk -F '/' 'NR%2{printf $NF" ";next} {print $NF}' ${gtm_dbkeys}.orig`
@ datkey_pairs_count = $#datkey_pairs
@ i = 1
while ($i <= $datkey_pairs_count)
	# Save the database and region names for later use.
	set dat = $datkey_pairs[$i]
	set reg = `$gtm_dist/mumps -run %XCMD 'set reg="" for  set reg=$view("gvnext",reg) quit:(""=reg)  set dat=$view("gvfile",reg),dat=$piece(dat,"/",$length(dat,"/")) write:(dat="'$dat'") reg'`
	@ i++
	set key = $datkey_pairs[$i]2

	if (! $?gtm_test_replay) then
		@ use_absolute_path = `$gtm_dist/mumps -run rand 2 1 0`
		echo "setenv use_absolute_path_2_$i $use_absolute_path" >> settings.csh
	else
		set var = '$use_absolute_path_2_'$i
		eval "@ use_absolute_path = $var"
	endif
	if ($use_absolute_path) then
		set key = `pwd`/${key}
	endif

	echo "dat $dat" >> ${gtm_dbkeys}.new
	echo "key $key" >> ${gtm_dbkeys}.new

	# Do MUPIP REORG -ENCRYPT.
	set syslog_time_before = `date +"%b %e %H:%M:%S"`
	$MUPIP reorg -encrypt=$key -region $reg >>&! mupip_reorg_encrypt.out
	set syslog_time_after = `date +"%b %e %H:%M:%S"`

	# Depending on whether the database was made encryptable, set expectations accordingly.
	if ($set_encryptable2) then
		$grep -q "Region $reg : MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt.out
		set stat = $status
	else
		$grep -q "Region $reg : cannot operate on a database not configured for encryption" mupip_reorg_encrypt.out
		set stat = $status
		if (! $status) then
			mv mupip_reorg_encrypt.out mupip_reorg_encrypt.outx
		endif
	endif

	if ($status) then
		echo "TEST-E-FAIL, Unexpected status of MUPIP REORG -ENCRYPT operation. See mupip_reorg_encrypt.out for details"
		exit 1
	endif

	# If the database was encryptable, expect a few more things to happen.
	if ($set_encryptable2) then
		set syslogfile = "syslog_case2_${i}.txt"
		$gtm_tst/com/getoper.csh "$syslog_time_before" "$syslog_time_after" $syslogfile "" "MUREENCRYPTEND, Database $cwd/$dat : MUPIP REORG ENCRYPT finished"

		# In case of journaling, expect two journal switches.
		if ($use_journaling) then
			set mjl = ${dat:s/dat/mjl/}
			@ jnl_switch_count = `$grep -cE "NEWJNLFILECREAT.*$cwd/${mjl}" $syslogfile`
			if (2 != $jnl_switch_count) then
				echo "TEST-E-FAIL, MUPIP REORG -ENCRYPT caused $jnl_switch_count journal switch(es) instead of 2. See $syslogfile for details"
				exit 1
			endif
		endif
	endif

	# Expect the appropriate IV status.
	$gtm_tst/com/dse_command.csh -region $reg -do 'dump -file -all'
	set null_iv = `cat dse_commands.out |& $tst_awk '/null IV/ {print $7}'`
	mv dse_commands.out dse_dump_${reg}.out
	if (($set_encryptable2 && ("TRUE" == $null_iv)) || ((! $set_encryptable2) && $use_null_iv && ("FALSE" == $null_iv))) then
		echo "TEST-E-FAIL, On region $reg after MUPIP REORG -ENCRYPT the database null IV status is $null_iv"
		exit 1
	endif
	@ i++
end

# Verify that everything could be decrypted with a combination of the old and new keys.
echo
echo "Verify decryption with old and new keys."
$gtm_dist/mumps -run %XCMD "$data_verification"

# Verify that everything could be decrypted using only the new keys.
echo
echo "Verify decryption with new keys only."
setenv gtmcrypt_config ${gtmcrypt_config_base}.new
$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.new $gtmcrypt_config
$gtm_dist/mumps -run %XCMD "$data_verification"

# Validate and back up.
echo
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.gld *.out *.cfg" mv nozip
$gtm_tst/com/backup_dbjnl.csh bak2 "*.bak *.orig *.new" cp nozip
