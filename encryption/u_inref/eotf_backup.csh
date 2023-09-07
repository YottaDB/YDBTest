#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2019-2023 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test the backup functionality against concurrent (re)encryption:
#
#   a) Backup version has been upgraded to 7.
#   b) (Re)encryption can be performed while MUPIP BACKUP is underway.
#   c) Backup that started before (re)encryption commenced can be restored with only the original key in configuration file.
#   d) MUPIP BACKUP can be performed while the database is being (re)encrypted.
#   e) Backup that started after (re)encryption commenced can only be restored with both keys present in configuration file.
#   f) MUPIP RESTORE cannot be performed while the database is being (re)encrypted.
#
#   This test optionally
#
#   - uses journaling; and
#   - starts with an unencrypted database.

# Encryption cannot work on V4 databases.
setenv gtm_test_mupip_set_version "disable"

# Extra debugging options slow down this test too much.
unsetenv gtmdbglvl

source $gtm_tst/com/set_random_limits.csh

if (! $?gtm_test_replay) then
	set random_options = `$gtm_dist/mumps -run rand 2 2 0`

	# Choose whether to use journaling.
	@ use_journaling = $random_options[1]
	echo "setenv use_journaling $use_journaling" >> settings.csh

	# Choose whether we start with an unencrypted database.
	@ unencrypted = $random_options[2]
	echo "setenv unencrypted $unencrypted" >> settings.csh
endif

if ($unencrypted) then
	setenv test_encryption NON_ENCRYPT
endif

# Apply journaling, if necessary.
if ($use_journaling) then
	setenv gtm_test_jnl SETJNL
endif

# Create the database.
$gtm_tst/com/dbcreate.csh mumps 1 . $RAND_RECORD_SIZE . . 4096

# If we started with an unencrypted database, set necessary variables for future encryption and make the region encryptable.
if ($unencrypted) then
	setenv gtmcrypt_config gtmcrypt.cfg
	setenv gtm_dbkeys db_mapping_file
	setenv gtm_passwd `echo ydbrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	touch $gtm_dbkeys $gtmcrypt_config
	$MUPIP set -encryptable -region "*" >&! mupip_set_encryptable.out
endif

# Take a full backup to avoid potential TN misalignments with future incremental backups.
$MUPIP backup DEFAULT backup.dat >&! mupip_backup.out

# Take a copy of the pre-population database, journal, and configuration file.
cp mumps.dat mumps.dat.orig
cp $gtmcrypt_config ${gtmcrypt_config}.orig
if ($use_journaling) then
	cp mumps.mjl mumps_mjl.orig
endif

# Populate the database and move the file away (to be used by the below test cases).
$gtm_dist/mumps -run %XCMD 'for i=1:1:200 set ^a(i)=$justify(i,'$RAND_RECORD_SIZE')'
mv mumps.dat mumps.dat.filled

# Prepare the extra key.
setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps_dat_key2
unsetenv gtm_encrypt_notty

# Add the extra key to the encryption configuration.
echo "dat mumps.dat" > ${gtm_dbkeys}.bak
echo "key mumps_dat_key2" >> ${gtm_dbkeys}.bak
cat $gtm_dbkeys >> ${gtm_dbkeys}.bak
mv ${gtm_dbkeys}.bak $gtm_dbkeys
$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys $gtmcrypt_config
set new_key = mumps_dat_key2

$gtm_tst/com/backup_dbjnl.csh bak0 "*.out *.mjl*" mv nozip

echo
echo "Case 1. Starting (re)encryption while MUPIP BACKUP is underway"
cp mumps.dat.filled mumps.dat
# Wrong journal file, but should not matter.
if ($use_journaling) then
	cp mumps_mjl.orig mumps.mjl
endif

# Start MUPIP BACKUP in the background.
($MUPIP backup -bytestream DEFAULT mumps.dat.bak >&! mupip_backup.out &; echo $! > pid.out) >&! /dev/null

$gtm_tst/com/wait_for_log.csh -waitcreation -log mupip_backup.out -duration 30 -message "MUPIP backup of database file"

# Start a MUPIP REORG -ENCRYPT.
$MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt.out

@ pid = `cat pid.out`
$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

$grep -q "BACKUP COMPLETED" mupip_backup.out
if ($status) then
	echo "TEST-E-FAIL, MUPIP BACKUP failed. See mupip_backup.out for details"
	exit 1
endif

$grep -q "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt.out
if ($status) then
	echo "TEST-E-FAIL, MUPIP REORG -ENCRYPT failed. See mupip_reorg_encrypt.out for details"
	exit 1
endif

echo
od -N 26 -tc mumps.dat.bak

echo
$gtm_tst/com/dbcheck.csh

$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat *.out *.mjl*" mv nozip
$gtm_tst/com/backup_dbjnl.csh bak1 "*.bak" cp nozip


echo
echo "Case 2. Ensuring that backup can be restored with one key in configuration file"
cp mumps.dat.orig mumps.dat
if ($use_journaling) then
	cp mumps_mjl.orig mumps.mjl
endif
setenv gtmcrypt_config_orig $gtmcrypt_config
setenv gtmcrypt_config ${gtmcrypt_config}.orig

# Restore the backup file taken previously.
$MUPIP restore mumps.dat mumps.dat.bak >&! mupip_restore.out

$grep -q "RESTORESUCCESS" mupip_restore.out
if ($status) then
	echo "TEST-E-FAIL, MUPIP RESTORE failed. See mupip_restore.out for details"
	exit 1
endif

echo
$gtm_tst/com/dbcheck.csh

$gtm_tst/com/backup_dbjnl.csh bak2 "*.dat *.out *.bak *.mjl*" mv nozip

setenv gtmcrypt_config $gtmcrypt_config_orig

if ("pro" != "$tst_image") then
	echo
	echo "Case 3. Starting MUPIP BACKUP while (re)encryption is underway"
	cp mumps.dat.filled mumps.dat
	# Wrong journal file, but should not matter.
	if ($use_journaling) then
		cp mumps_mjl.orig mumps.mjl
	endif

	# Start MUPIP REORG -ENCRYPT and make sure it does not finish before we start MUPIP BACKUP.
	setenv gtm_white_box_test_case_number 123	# WBTEST_SLEEP_IN_MUPIP_REORG_ENCRYPT
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_count 1
	($MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt.out &; echo $! > pid.out) >&! /dev/null
	unsetenv gtm_white_box_test_case_enable

	$gtm_tst/com/wait_for_log.csh -waitcreation -log mupip_reorg_encrypt.out -duration 30 -message "Starting the sleep"

	# Now start MUPIP BACKUP.
	$MUPIP backup -bytestream DEFAULT mumps.dat.bak >&! mupip_backup.out

	@ pid = `cat pid.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

	$grep -q "BACKUP COMPLETED" mupip_backup.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP BACKUP failed. See mupip_backup.out for details"
		exit 1
	endif

	$grep -q "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP REORG -ENCRYPT failed. See mupip_reorg_encrypt.out for details"
		exit 1
	endif

	echo
	od -N 26 -tc mumps.dat.bak

	echo
	$gtm_tst/com/dbcheck.csh

	$gtm_tst/com/backup_dbjnl.csh bak3 "*.dat *.out *.mjl*" mv nozip
	$gtm_tst/com/backup_dbjnl.csh bak3 "*.bak" cp nozip

	echo
	echo "Case 4. Ensuring that backup needs both keys in configuration file to be restored"
	cp mumps.dat.orig mumps.dat
	if ($use_journaling) then
		cp mumps_mjl.orig mumps.mjl
	endif
	setenv gtmcrypt_config_orig $gtmcrypt_config
	setenv gtmcrypt_config ${gtmcrypt_config}.orig

	# Restore the backup taken previously.
	$MUPIP restore mumps.dat mumps.dat.bak >&! mupip_restore1.out

	# Verify that backup could not be restored without all keys.
	$gtm_tst/com/check_error_exist.csh mupip_restore1.out "CRYPTKEYFETCHFAILED" "MUPRESTERR"

	echo
	$gtm_tst/com/dbcheck.csh

	setenv gtmcrypt_config $gtmcrypt_config_orig

	# Now that all keys are present, make sure that the restoration can proceed.
	$MUPIP restore mumps.dat mumps.dat.bak >&! mupip_restore2.out

	$grep -q "RESTORESUCCESS" mupip_restore2.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP RESTORE failed. See mupip_restore2.out for details"
		exit 1
	endif

	echo
	$gtm_tst/com/dbcheck.csh

	$gtm_tst/com/backup_dbjnl.csh bak4 "*.dat *.out* *.mjl*" mv nozip
	$gtm_tst/com/backup_dbjnl.csh bak4 "*.bak" cp nozip


	echo
	echo "Case 5. RESTORE cannot start while the database is being (re)encrypted"
	cp mumps.dat.orig mumps.dat
	if ($use_journaling) then
		cp mumps_mjl.orig mumps.mjl
	endif

	# Start MUPIP REORG -ENCRYPT first and make sure it does not finish before the MUPIP RESTORE process kicks in.
	setenv gtm_white_box_test_case_enable 1
	setenv gtm_white_box_test_case_count 0
	($MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt.out &; echo $! > pid.out) >&! /dev/null
	unsetenv gtm_white_box_test_case_enable

	$gtm_tst/com/wait_for_log.csh -waitcreation -log mupip_reorg_encrypt.out -duration 30 -message "Starting the sleep"

	# Do MUPIP RESTORE now.
	$MUPIP restore mumps.dat mumps.dat.bak >&! mupip_restore.out

	@ pid = `cat pid.out`
	$kill -USR1 $pid
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 60

	$grep -q "File already open by another process" mupip_restore.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP RESTORE did not report concurrent database use. See mupip_restore.out for details"
		exit 1
	endif

	$gtm_tst/com/check_error_exist.csh mupip_restore.out "MUPRESTERR"

	echo
	$gtm_tst/com/dbcheck.csh

	$gtm_tst/com/backup_dbjnl.csh bak5 "*.dat *.out* *.bak *.mjl*" mv nozip
endif
