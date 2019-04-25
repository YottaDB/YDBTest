#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018-2019 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Test journal-based recovery against database (re)encryption:
#
#   a) MUPIP JOURNAL -RECOVER can start while (re)encryption is in progress (except when MUPIP REORG -ENCRYPT is holding the FTOK semaphore).
#   b) MUPIP REORG -ENCRYPT can start while recovery is in progress (but has to wait for MUPIP JOURNAL -RECOVER to release the FTOK semaphore).
#
#   This test randomly
#
#   - starts with an unencrypted database;
#   - schedules recover to run after (re)encryption has finished;
#   - chooses between before and nobefore journaling;
#   - chooses between forward and backward recovery;
#   - picks a sleep duration between the REORG and RECOVER process, whatever the order; and
#   - decides whether to use -since and -before qualifiers for recovery.

setenv gtm_test_mupip_set_version "disable"

unsetenv gtmdbglvl

if (! $?gtm_test_replay) then
	set random_options = `$gtm_dist/mumps -run rand 2 5 0`

	# Choose whether to do backward or forward recovery.
	@ backward = $random_options[1]
	echo "setenv backward $backward" >> settings.csh

	# Choose whether to use the BEFORE qualifier.
	@ do_before = $random_options[2]
	echo "setenv do_before $do_before" >> settings.csh

	# Choose whether we start with an unencrypted database.
	@ unencrypted = $random_options[3]
	echo "setenv unencrypted $unencrypted" >> settings.csh

	# Choose whether to do recovery before or after the (re)encryption.
	# Recover cannot start first because of the below
	# "The reorg encrypt came into db_init() right at the same time that forward recovery had already done a gds_rundown() in mur_close_files()
	# but had not yet done the db_ipcs_reset() call. So the semid/shmid were still valid in the db file header but they had already been removed"
	# Check <jnl_recover_reorg_encrypt_REQRUNDOWN>
	@ recover_first = 0
	echo "setenv recover_first $recover_first" >> settings.csh

	# Choose the sleep duration.
	if ($recover_first) then
		# In case of a recovery happening first, it is the time before starting the (re)encryption.
		@ sleep_duration = `$gtm_dist/mumps -run rand 10 1 0`
	else if ($backward) then
		# In case of a (re)encryption happening first, it is the time before doing the recovery. If the time is above 10,
		# simply wait for the (re)encryption to complete first.
		@ sleep_duration = `$gtm_dist/mumps -run rand 15 1 0`
	else
		# Similarly to above, unconditionally wait for the (re)encryption to complete before doing a forward recovery.
		@ sleep_duration = 15
	endif
	echo "setenv sleep_duration $sleep_duration" >> settings.csh

	# Choose whether to use a SINCE qualifier in case of backward recovery.
	if ($backward) then
		@ do_since = $random_options[5]
	else
		@ do_since = 0
	endif
	echo "setenv do_since $do_since" >> settings.csh

	# Choose the maximum record size.
	source $gtm_tst/com/set_random_limits.csh
	echo "setenv RAND_RECORD_SIZE $RAND_RECORD_SIZE" >> settings.csh
endif

if ($backward) then
	source $gtm_tst/com/gtm_test_setbeforeimage.csh
endif

if ($unencrypted) then
	setenv test_encryption NON_ENCRYPT
endif

# Enable journaling.
setenv gtm_test_jnl SETJNL

echo "Create the database"
$gtm_tst/com/dbcreate.csh mumps 1 . $RAND_RECORD_SIZE . . 4096

# If we started with an unencrypted database, set necessary variables for future encryption and make the region encryptable.
if ($unencrypted) then
	setenv gtmcrypt_config gtmcrypt.cfg
	setenv gtm_dbkeys db_mapping_file
	setenv gtm_passwd `echo ydbrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	touch $gtm_dbkeys
	touch $gtmcrypt_config
	$MUPIP set -encryptable -region "*" >&! mupip_set_encryptable.out
endif

if (! $backward) then
	cp mumps.dat mumps.dat.bak
endif

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

# Submit a large number of updates to the database.
echo
echo "Write database updates"
@ start_in_sec = `date +%s`
$gtm_dist/mumps -run %XCMD 'for i=1:1:100 set ^a(i)=$justify(i,'$RAND_RECORD_SIZE')'
@ end_in_sec = `date +%s`

# In case we are using the BEFORE qualifier, find the timestamp of the first logical update.
echo
echo "Determine first timestamp, if necessary"
if ($do_before) then
	set first_mjl = `ls -1rt mumps.mjl* | $head -n 1`
	$MUPIP journal -extract -forward -detail $first_mjl >&! mupip_journal_extract.out
	set first_timestamp_in_hor = `$tst_awk -F '\\' '/SET/ {print $2; exit}' mumps.mjf`
	set first_timestamp = `$gtm_dist/mumps -run %XCMD 'write $zdate("'"$first_timestamp_in_hor"'","YEAR MM DD 24 60 SS")'`
	@ first_timestamp_in_sec = `echo | $tst_awk '{print mktime("'"$first_timestamp"'");}'` # ` for vim highlighting
endif

set format = "%d-%b-%Y %H:%M:%S"

if ($backward) then
	set recover_opts = "-backward"
else
	set recover_opts = "-forward"
endif

# Calculate the total duration of the database updates.
@ duration_in_sec = $end_in_sec - $start_in_sec

# If we are using the SINCE qualifier, figure out an appropriate time to supply.
echo
echo "Determine SINCE time, if necessary"
if ($do_since) then
	if (0 == $duration_in_sec) then
		@ since_in_sec = $start_in_sec
	else
		@ since_in_sec = `$gtm_dist/mumps -run %XCMD 'write '$start_in_sec'+$random('$duration_in_sec'+1)'`
	endif

	set since_time = `echo | $tst_awk '{print strftime("'"${format}"'",'${since_in_sec}');}'`
	set recover_opts = "$recover_opts -since="'"'"$since_time"'"'
endif

echo
echo "Determine BEFORE time, if necessary"
# Similarly with BEFORE, figure out what is appropriate.
if ($do_before) then
	if ($do_since) then
		@ before_interval_in_sec = $end_in_sec - $since_in_sec
		if (0 == $before_interval_in_sec) then
			@ before_in_sec = $since_in_sec
		else
			@ before_in_sec = `$gtm_dist/mumps -run %XCMD 'write '$since_in_sec'+$random('$before_interval_in_sec'+1)'`
		endif
	else
		@ before_in_sec = `$gtm_dist/mumps -run %XCMD 'write '$start_in_sec'+$random('$duration_in_sec'+1)'`
	endif

	if ($first_timestamp_in_sec >= $before_in_sec) then
		@ before_in_sec = $first_timestamp_in_sec + 1
	endif

	set before_time = `echo | $tst_awk '{print strftime("'"${format}"'",'${before_in_sec}');}'`
	set recover_opts = "$recover_opts -before="'"'"$before_time"'"'
endif

echo
echo "# Recovery command is mupip journal -recover GTM_TEST_DEBUGINFO $recover_opts mumps.mjl"

$gtm_tst/com/backup_dbjnl.csh bak "*.dat *.mjl*" cp nozip

if ($recover_first) then
	if (! $backward) then
		mv mumps.dat mumps.dat.filled
		mv mumps.dat.bak mumps.dat
	endif

	echo
	echo "Start recovery"
	($MUPIP journal -recover $recover_opts mumps.mjl >&! mupip_journal_recover.out &; echo $! > recov_pid.out) >&! /dev/null
	sleep $sleep_duration
endif

echo
echo "Start (re)encryption"
($MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt.out &; echo $! > reorg_pid.out) >&! /dev/null
@ reorg_pid = `cat reorg_pid.out`
@ wait_for_reorg_to_complete = 0

if (! $recover_first) then
	# If sleep duration exceeds 10 seconds, wait for the REORG to finish.
	if (10 < $sleep_duration) then
		@ wait_for_reorg_to_complete = 1
		$gtm_tst/com/wait_for_proc_to_die.csh $reorg_pid 300
	else
		sleep $sleep_duration
	endif
	if (! $backward) then
		mv mumps.dat mumps.dat.filled
		mv mumps.dat.bak mumps.dat
	endif
	echo
	echo "Start recovery"
	($MUPIP journal -recover $recover_opts mumps.mjl >&! mupip_journal_recover.out &; echo $! > recov_pid.out) >&! /dev/null
endif

# Recovery requires stand-alone access, which it might not get due to concurrent REORG activity, so try multiple times.
@ recover_attempts = 0
while (20 > $recover_attempts)
	@ recov_pid = `cat recov_pid.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $recov_pid 300

	$grep -q "Resource temporarily unavailable" mupip_journal_recover.out
	if ($status) then
		@ recover_attempts = 0
		break
	endif

	@ recover_attempts++
	mv mupip_journal_recover.out mupip_journal_recover${recover_attempts}.outx
	@ sleep_duration = `$gtm_dist/mumps -run rand 10 1 0`
	sleep $sleep_duration
	($MUPIP journal -recover $recover_opts mumps.mjl >&! mupip_journal_recover.out &; echo $! > recov_pid.out) >&! /dev/null
end

# After all recovery attempts if we still have not succeeded, report an error.
if (0 != $recover_attempts) then
	$grep -q "Resource temporarily unavailable" mupip_journal_recover.out
	if ($status) then
		echo "TEST-E-FAIL, MUPIP JOURNAL -RECOVER could not get exclusive access to the database in 20 attempts"
		exit 1
	endif
endif

if (! $wait_for_reorg_to_complete) then
	$gtm_tst/com/wait_for_proc_to_die.csh $reorg_pid 300
endif

$grep -q "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt.out
if ($status) then
	echo "TEST-E-FAIL, MUPIP REORG -ENCRYPT failed. See mupip_reorg_encrypt.out for details"
	exit 1
endif

$grep -q "%YDB-S-JNLSUCCESS, Recover successful" mupip_journal_recover.out
if ($status) then
	echo "TEST-E-FAIL, MUPIP JOURNAL -RECOVER failed. See mupip_journal_recover.out for details"
	exit 1
endif

echo
echo "Check integrity"
$gtm_tst/com/dbcheck.csh
