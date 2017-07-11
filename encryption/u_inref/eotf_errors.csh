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

# Validate various (re)encryption-specific errors:
#
#   a) Specified key is not found in the configuration file.
#   b) Specified key corresponds to a different database.
#   c) Operation attempted in MM.
#   d) Read-only database.
#   e) Concurrent MUPIP REORG ENCRYPTs.
#   f) Incompatible REORG qualifiers.
#   g) Attempt to resume (re)encryption with a different key.
#   h) Attempt to resume (re)encryption after the key has been removed.
#   i) Attempt to mark encryption complete during an ongoing MUPIP REORG ENCRYPT.
#   j) Consecutive MUPIP REORG ENCRYPTs without marking encryption complete in between.
#   k) Attempt to downgrade a partially (re)encrypted database.
#   l) Attempt to make the database unencryptable in the middle of (re)encryption.
#
#   This test additionally makes sure that
#
#   - Basic resume works.

# Encryption cannot work on V4 databases.
setenv gtm_test_mupip_set_version "disable"

# Create a database with a few basic updates.
$gtm_tst/com/dbcreate.csh mumps
$gtm_dist/mumps -run %XCMD 'set ^a=1,^b=2,^c=3'

# Move the original database and global directory files away to have them restored at a later point.
mv mumps.dat mumps.dat.orig
mv mumps.gld mumps.gld.orig
set good_key = `$tst_awk -F '"' '/key:.*mumps.*/ {print $2}' $gtmcrypt_config`
cp $gtm_dbkeys ${gtm_dbkeys}.priorver
mv $gtm_dbkeys ${gtm_dbkeys}.orig
mv $gtmcrypt_config ${gtmcrypt_config}.orig
echo

echo "# Case 1. Operation attempted in MM."
setenv test_encryption NON_ENCRYPT
setenv acc_meth "MM"
$gtm_tst/com/dbcreate.csh mumps
setenv test_encryption ENCRYPT
setenv acc_meth "BG"
echo

cp ${gtmcrypt_config}.orig $gtmcrypt_config
cp ${gtm_dbkeys}.orig $gtm_dbkeys
$gtm_dist/mumps -run %XCMD 'set ^a=1,^b=2,^c=3'

$MUPIP set -encryptable -region "*"
$MUPIP reorg -encrypt=$good_key -region "*"
mv mumps.dat mumps.dat.mm
mv mumps.gld mumps.gld.mm
echo

echo "# Case 1B. Operation attempted with V4 blocks"
setenv test_encryption NON_ENCRYPT
setenv gtm_test_mupip_set_version "V4"
$gtm_tst/com/dbcreate.csh mumps
setenv test_encryption ENCRYPT
setenv gtm_test_mupip_set_version "disable"
cp ${gtmcrypt_config}.orig $gtmcrypt_config
cp ${gtm_dbkeys}.orig $gtm_dbkeys
set verbose
$MUPIP set -encryptable -region "*"
$MUPIP reorg -encrypt=$good_key -region "*"
$MUPIP set -encryptioncomplete -region "*"
unset verbose
mv mumps.dat mumps.dat.v4
mv mumps.gld mumps.gld.v4

echo "# Case 2. Specified key is not found in the configuration file."
mv mumps.dat.orig mumps.dat
mv mumps.gld.orig mumps.gld
set bad_key = `$gtm_exe/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
$MUPIP reorg -encrypt=$bad_key -region "*"
echo

echo "# Case 3. Specified key corresponds to a different database."
setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 ${good_key}.other
unsetenv gtm_encrypt_notty

cat $gtm_dbkeys >> ${gtm_dbkeys}.bak
$tst_awk '/key / {print $0".other"} /dat / {print $0".other"}' $gtm_dbkeys >> ${gtm_dbkeys}.bak
$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.bak $gtmcrypt_config
rm ${gtm_dbkeys}.bak

$MUPIP reorg -encrypt=$good_key.other -region "*"
echo

echo "# Case 4. Read-only database."
chmod u-w mumps.dat
$MUPIP reorg -encrypt=$good_key -region "*"
chmod u+w mumps.dat
echo

if ("pro" != "$tst_image") then
	echo "# Case 5. Concurrent MUPIP REORG ENCRYPTs."
	setenv gtm_encrypt_notty "--no-permission-warning"
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 ${good_key}.new
	unsetenv gtm_encrypt_notty

	$tst_awk '/key / {print $0".new"} /dat / {print}' $gtm_dbkeys > ${gtm_dbkeys}.bak
	cat ${gtm_dbkeys}.bak >> $gtm_dbkeys
	rm ${gtm_dbkeys}.bak
	$gtm_dist/mumps -run CONVDBKEYS $gtm_dbkeys $gtmcrypt_config

	# Ensure that MUPIP REORG -ENCRYPT does not finish before we can schedule a concurrent one.
	setenv gtm_white_box_test_case_number 123	# WBTEST_SLEEP_IN_MUPIP_REORG_ENCRYPT
	setenv gtm_white_box_test_case_enable 1
	($MUPIP reorg -encrypt=$good_key.new -region "*" >&! case5.out &; echo $! > mupip_pid.out) >&! /dev/null
	unsetenv gtm_white_box_test_case_enable
	$gtm_tst/com/wait_for_log.csh -waitcreation -log case5.out -duration 30 -message "Starting the sleep"

	$MUPIP reorg -encrypt=$good_key.new -region "*"
	echo

	echo "# Case 6. Attempt to mark encryption complete during an ongoing MUPIP REORG ENCRYPT."
	$MUPIP set -encryptioncomplete -region "*"
	echo

	echo "# Case 7. Attempt mupip extract -format=bin while mupip reorg -encrypt is running"
	$MUPIP extract -format=bin extr.bin
	echo

	echo "# Signal the mupip reorg -encrypt process to exit"
	@ mupip_pid = `cat mupip_pid.out`
	$kill -USR1 $mupip_pid
	$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 60
	echo

	echo "# Case 8. Consecutive MUPIP REORG ENCRYPTs without marking encryption complete in between."
	$MUPIP reorg -encrypt=$good_key -region "*"
	echo
	$MUPIP set -encryptioncomplete -region "*"
	echo

	echo "# Case 9. Attempt to make the database unencryptable in the middle of (re)encryption."
	# Ensure that MUPIP REORG -ENCRYPT does not finish before we can attempt to mark the database unencryptable.
	setenv gtm_white_box_test_case_number 123	# WBTEST_SLEEP_IN_MUPIP_REORG_ENCRYPT
	setenv gtm_white_box_test_case_enable 1
	($MUPIP reorg -encrypt=$good_key -region "*" >&! case8.out &; echo $! > mupip_pid2.out) >&! /dev/null
	unsetenv gtm_white_box_test_case_enable
	$gtm_tst/com/wait_for_log.csh -waitcreation -log case8.out -duration 30 -message "Starting the sleep"

	@ mupip_pid = `cat mupip_pid2.out`
	$kill -TERM $mupip_pid
	$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 60
	$gtm_tst/com/check_error_exist.csh case8.out "FORCEDHALT" > /dev/null
	source $gtm_tst/com/leftover_ipc_cleanup_if_needed.csh $0 # do rundown if needed before requiring standalone access
	$MUPIP set -noencryptable -region "*"
	echo

	echo "# Case 10. Attempt to resume (re)encryption with a different key."
	$MUPIP reorg -encrypt=$good_key.new -region "*"
	echo

	echo "# Case 11. Attempt to resume (re)encryption with the key gone."
	mv $good_key $good_key.gone
	$MUPIP reorg -encrypt=$good_key -region "*"
	mv $good_key.gone $good_key
	echo
	$MUPIP reorg -encrypt=$good_key -region "*"
	echo
endif

echo "# Case 12. Incompatible REORG qualifiers."
set qualifiers = 'downgrade exclude="^a" fill_factor=5 index_fill_factor=5 resume select="^a" truncate upgrade user_defined_reorg="^a"'
foreach qualifier ($qualifiers)
	$MUPIP reorg -encrypt=$good_key -region "*" -$qualifier
end
echo

# Encryption plug-ins within the prior version range enforced below are unstable on AIX boxes and cannot be used.
# In non-gg setup, dbg builds of [V53004,V60000) don't exist so disable this part of the test in that case.
if (("AIX" != "$HOSTOS") && ("pro" != "$tst_image") && ("dbg" != "$tst_image")) then
	echo "# Case 13. Attempt to downgrade a partially (re)encrypted database."

	echo "# Randomly choose any version with null IVs."
	if (! $?gtm_test_replay) then
		set prior_ver = `$gtm_tst/com/random_ver.csh -lt V60000 -gte V53004`
		if ("$prior_ver" =~ "*-E-*") then
			echo "No prior versions available: $prior_ver"
			exit -1
		endif
		echo "setenv prior_ver $prior_ver" >> settings.csh
	endif
	echo "$prior_ver" > priorver.out
	source $gtm_tst/com/ydb_prior_ver_check.csh $prior_ver
	source $gtm_tst/com/switch_gtm_version.csh $prior_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	echo

	mv ${gtm_dbkeys} ${gtm_dbkeys}.curver
	mv ${gtmcrypt_config} ${gtmcrypt_config}.curver
	setenv gtm_dbkeys ${gtm_dbkeys}.priorver
	$gtm_tst/com/dbcreate.csh mumps 1 64 512 >&! dbcreate_priorver.out

	echo "# Switch to current version."
	source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
	source $gtm_tst/$tst/u_inref/set_encr_algorithm.csh
	$GDE exit >&! gde.out
	mv ${gtmcrypt_config}.curver ${gtmcrypt_config}
	echo

	echo "# Update limits and database file header."
	$gtm_dist/mumps -run %XCMD 'set ^a=1 kill ^a'
	$MUPIP integ -reg "*" -noonline >&! integ.out
	echo

	setenv gtm_white_box_test_case_number 123	# WBTEST_SLEEP_IN_MUPIP_REORG_ENCRYPT
	setenv gtm_white_box_test_case_enable 1
	# Database should be encrypted with $good_key at this point, so choose a different key.
	($MUPIP reorg -encrypt=${good_key}.new -region "*" >&! case12.out &; echo $! > mupip_pid3.out) >&! /dev/null
	unsetenv gtm_white_box_test_case_enable
	$gtm_tst/com/wait_for_log.csh -waitcreation -log case12.out -duration 30 -message "Starting the sleep"

	@ mupip_pid = `cat mupip_pid3.out`
	$kill -TERM $mupip_pid
	$gtm_tst/com/wait_for_proc_to_die.csh $mupip_pid 60
	$gtm_tst/com/check_error_exist.csh case12.out "FORCEDHALT" > /dev/null

	echo "# Attempt downgrading the database."
	echo "yes" | $MUPIP downgrade mumps.dat -version=V5
	echo
endif

$gtm_tst/com/dbcheck.csh
