#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv gtm_test_eotf_keys 2
setenv gtm_test_mupip_set_version DISABLE
# Case 1 : Encrypting an unencrypted database while the database is being populated

echo "# Case 1 : Encrypting an unencrypted database while the database is being populated"

echo "# Setup encryption keys"
$gtm_tst/com/create_key_file.csh >& create_key_file.out
cp $gtmcrypt_config ${gtmcrypt_config}.orig

echo "# Create database in NON_ENCRYPT mode"
setenv test_encryption NON_ENCRYPT
$gtm_tst/com/dbcreate.csh mumps >&! db_create_case1.out
cp ${gtmcrypt_config}.orig $gtmcrypt_config
$MUPIP set -encryptable -region DEFAULT

echo "# Start just the passive source server with updates enabled"
source $gtm_tst/com/passive_start_upd_enable.csh >& START_passive.out

cat > updates.m << CAT_EOF
updates	;
	set ^a=1
	zsystem ("$gtm_tst/com/wait_for_log.csh -log reencryption_3.done -waitcreation")
	set ^b=1
	quit
CAT_EOF

echo "# Run the process that does global updates, in the background"
($gtm_exe/mumps -run updates > run_updates.out & ; echo $! > bgupdate.pid ) >&! run_updates_bg.out

echo "# Wait for the first global to be set"
$gtm_exe/mumps -run waitforglobal

echo "# Encrypt the database with mumps_dat_key"
$MUPIP reorg -encrypt=mumps_dat_key -reg DEFAULT
$MUPIP set -encryptioncomplete -reg DEFAULT
touch reencryption_3.done

echo "# Wait for the backround process to exit and shutdown the passive source server"
$gtm_tst/com/wait_for_proc_to_die.csh `cat bgupdate.pid`
$MUPIP replic -source -shutdown -timeout=0 >>& STOP_passive.out

echo "# Should see both the globals"
$gtm_exe/mumps -run %XCMD 'zwrite ^?.E'

$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh case1 "*.dat *.mjl* " mv nozip

echo "# Case 2 : Journal recover backward between two re-encryptions"
source $gtm_tst/com/gtm_test_setbeforeimage.csh
setenv gtm_test_jnl SETJNL
setenv test_encryption ENCRYPT
alias encrupd '$MUPIP reorg -encrypt=\!:1 -reg \!:2; $MUPIP set -encryptioncomplete -reg \!:2; $gtm_exe/mumps -run updates'

$gtm_tst/com/dbcreate.csh mumps 2

echo "# Setup keys"
cp $gtmcrypt_config ${gtmcrypt_config}.orig_case2
sed 's/a_dat_key_2/mumps_dat_key/' ${gtmcrypt_config}.orig_case2 >&! $gtmcrypt_config

cat > updates.m << CAT_EOF
updates	;
	if \$incr(^a)
	if \$incr(^b)
	if \$incr(^c)
CAT_EOF

echo "# Do simple updates"
$gtm_exe/mumps -run updates

echo "# Reencrypt AREG with mumps_dat_key and do some updates"
encrupd mumps_dat_key AREG
echo "# Reencrypt DEFAULT with mumps_dat_key_2 and do some updates"
encrupd mumps_dat_key_2 DEFAULT
sleep 1
echo "# Reencrypt DEFAULT with mumps_dat_key and do some updates"
encrupd mumps_dat_key DEFAULT
set time1 = `date +'%d-%b-%Y %H:%M:%S'`
echo "# Reencrypt DEFAULT with mumps_dat_key_2 and do some updates"
encrupd mumps_dat_key_2 DEFAULT

echo '# mupip journal recover to $time1 should succeed'
$MUPIP journal -recover -backward -since=\"$time1\" "*" >&! journal_recover_backward.out

$grep 'YDB-S-JNLSUCCESS' journal_recover_backward.out

$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh case1 "*.dat *.mjl* $gtmcrypt_config" mv nozip

echo "# Case 3 : reorg encrypt with one region read-only"
setenv gtm_test_jnl NON_SETJNL	# Journaling was required only for Case 2 above
setenv test_encryption ENCRYPT
$gtm_tst/com/dbcreate.csh mumps 3
echo "# Setup keys for this test case"
cp $gtmcrypt_config ${gtmcrypt_config}.orig_case3
sed 's/a_dat_key_2/mumps_dat_key_2/;s/b_dat_key_2/mumps_dat_key_2/' ${gtmcrypt_config}.orig_case3 >&! $gtmcrypt_config

echo "# Make b.dat read only and run reorg -encrypt -reg '*'"
set verbose
chmod 444 b.dat
$MUPIP reorg -encrypt=mumps_dat_key_2 -region "*" >&! reorg_encr_b_readonly.outx
# Since the order of regions is non-deterministic, grep one region at a time to confirm if re-encryption of  DEFAULT/AREG is successful
$grep 'AREG' reorg_encr_b_readonly.outx
$grep 'DEFAULT' reorg_encr_b_readonly.outx
# Expect error from BREG
$grep -vE 'AREG|DEFAULT|^$' reorg_encr_b_readonly.outx
$MUPIP set -encryptioncomplete -region "*" >&! encrypt_complete_b_readonly.outx
$grep 'a.dat' encrypt_complete_b_readonly.outx
$grep 'mumps.dat' encrypt_complete_b_readonly.outx
# Expect error from b.dat
$grep -vE 'a.dat|mumps.dat' encrypt_complete_b_readonly.outx
unset verbose
chmod 644 b.dat
$gtm_tst/com/dbcheck.csh
