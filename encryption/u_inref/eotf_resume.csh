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

# Test the resume functionality of encryption-on-the-fly:
#
#   a) Reencryption can be resumed upon interrupting a MUPIP REORG -ENCRYPT process with a SIGINT or SIGTERM.
#   b) Reencryption can be resumed after an interrupt and a subsequent MUPIP REORG (-TRUNCATE).
#
#   This test randomly decides whether to
#
#   - use journaling;
#   - interrupt MUPIP REORG -ENCRYPT processes with a SIGINT or SIGTERM;
#   - invoke MUPIP REORG upon interruptions;
#   - perform a database trunctation if MUPIP REORGs are done.

# Encryption cannot work on V4 databases.
setenv gtm_test_mupip_set_version "disable"

unsetenv gtmdbglvl

source $gtm_tst/com/set_limits.csh

if (! $?gtm_test_replay) then
	set random_options = `$gtm_dist/mumps -run rand 2 4 0`

	# Choose whether to use journaling.
	@ use_journaling = $random_options[1]
	echo "setenv use_journaling $use_journaling" >> settings.csh

	# Choose whether to use SIGTERM or SIGUSR1 to interrupt MUPIP REORG -ENCRYPT.
	@ use_term = $random_options[2]
	echo "setenv use_term $use_term" >> settings.csh

	# Choose whether to do a MUPIP REORG after an interruption.
	@ do_reorg = $random_options[3]
	echo "setenv do_reorg $do_reorg" >> settings.csh

	# Choose whether to use the TRUNCATE qualifier with MUPIP REORG.
	if ($do_reorg) then
		@ do_truncate = $random_options[4]
	else
		@ do_truncate = 0
	endif
	echo "setenv do_truncate $do_truncate" >> settings.csh
endif

if ($use_journaling) then
	setenv gtm_test_setjnl SETJNL
endif

# Create the database.
$gtm_tst/com/dbcreate.csh mumps 1 . $MAX_RECORD_SIZE . . 4096

echo
echo "Prefill the database."
if ($do_truncate) then
	# In case we are going to REORG the database, ensure there are some unused blocks.
	$gtm_dist/mumps -run %XCMD 'for i=1:1:100 set ^a(i)=$justify(i,'$MAX_RECORD_SIZE')'
	$gtm_dist/mumps -run %XCMD 'for i=1:2:100 kill ^a(i)'
else
	$gtm_dist/mumps -run %XCMD 'for i=1:1:50 set ^a(i)=$justify(i,'$MAX_RECORD_SIZE')'
endif

if ($use_term) then
	set signal = "TERM"
else
	set signal = "INT"
endif

if ($do_truncate) then
	set truncate = "-truncate"
else
	set truncate = ""
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
setenv gtmcrypt_config ${gtmcrypt_config_base}.both
$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys $gtmcrypt_config
set new_key = `$tst_awk -F '"' '/key:.*key2/ {print $2}' $gtmcrypt_config`

echo
echo "Reencrypt the database."

# Do up to 9 interrupts followed by optional MUPIP REORGs.
@ i = 0
while ($i < 9)
	($MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt${i}.out &; echo $! > pid${i}.out) >&! /dev/null
	$gtm_tst/com/wait_for_log.csh -waitcreation -log mupip_reorg_encrypt${i}.out -duration 30 -message "MUPIP REORG ENCRYPT started"
	@ pid = `cat pid${i}.out`
	$gtm_dist/mumps -run %XCMD 'hang $random(10)/100'
	$kill -$signal $pid >&! kill${i}.out
	@ kill_status = $status
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 60
	if ($kill_status) break

	if ($do_reorg) then
		$MUPIP reorg $truncate >&! mupip_reorg${i}.out
	endif
	@ i++
end

# REORG -ENCRYPT might still not have finished, so resume it for one last time.
$grep -q "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt*.out
if ($status) then
	($MUPIP reorg -encrypt=$new_key -region "*" >&! mupip_reorg_encrypt${i}.out &; echo $! > pid${i}.out) >&! /dev/null
	$gtm_tst/com/wait_for_log.csh -waitcreation -log mupip_reorg_encrypt${i}.out -duration 30 -message "MUPIP REORG ENCRYPT started"
	@ pid = `cat pid${i}.out`
	$gtm_tst/com/wait_for_proc_to_die.csh $pid 60
endif

# REORG -ENCRYPT might have been interrupted after it has already processed the data but before printing the final message. Acount for that.
$grep -q "A previous MUPIP REORG -ENCRYPT has finished" mupip_reorg_encrypt*.out
if ($status) then
	echo
	$grep "MUPIP REORG ENCRYPT finished" mupip_reorg_encrypt*.out
else
	echo
	echo "MUPIP REORG ENCRYPT finished"
endif

# Filter out the expected MUNOFINISH and FORCEDHALT messages out of the .out files.
foreach log (mupip_reorg_encrypt*.out)
	mv $log ${log}x
	if ($use_term) then
		$grep -Ev "(MUNOFINISH|FORCEDHALT)" ${log}x > $log
	else
		$grep -v MUNOFINISH ${log}x > $log
	endif
end

echo
$gtm_tst/com/dbcheck.csh
