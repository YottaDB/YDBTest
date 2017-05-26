#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Verify that when the keys for database files are changed, the new keys are used to create the new databases
# Creating three database files with three different keys (under one global directory).
# Creating binary extract containing all three regions (i.e., database file).
# Creating three new keys for the database files after removing  the original database files.
# Adding the new keys to the db key file (via add_db_key.sh) and using the same to create database files.
# Loading the binary extract. Delete the db key file. Creating a new db key file that only contains the new keys.
# Verifying that globals in all three regions (i.e., database files) can be accessed.
#
$gtm_tst/com/dbcreate.csh mumps 3

$GTM << EOF
set ^var=1
for i=1:5:2000  s ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)=i
for i=851:5:931  K ^var("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuv",i)
h
EOF

echo "# Extract in Binary format"
$MUPIP extract extr.bin -fo=binary >&! mupip_extract_bin.out
if ($status) then
	echo "# mupip binary extract failed. Check mupip_extract_bin.out. Will exit now"
	exit 1
endif

echo "# Do bytestream backup of DEFAULT region"
$MUPIP backup -bytestream DEFAULT old_backup >&! mupip_backup_bytestream.out
if ($status) then
	echo "# mupip bytestream backup failed. Check mupip_backup_bytestream.out. Will exit now"
	exit 1
endif

$gtm_tst/com/backup_dbjnl.csh bak1 "*.dat" mv

# gpg gives some extra warnings along with the randomly generated key on few platforms. Redirecting the gpg output to some file and using grep -v helps to resolve these reference file differences.
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 new_mumps_key $user_emailid >& encrypt_db_key.out
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 new_a_key $user_emailid >>& encrypt_db_key.out
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 new_b_key $user_emailid >>& encrypt_db_key.out

cp $gtmcrypt_config tmp_gtmcrypt.cfg

echo "# Recreate database"
echo "dat $PWD/mumps.dat"		>>&! new_dbkeys.out
echo "key $PWD/mumps_dat_key"		>>&! new_dbkeys.out
echo "dat $PWD/mumps.dat"		>>&! new_dbkeys.out
echo "key $PWD/new_mumps_key"		>>&! new_dbkeys.out
echo "dat $PWD/a.dat"			>>&! new_dbkeys.out
echo "key $PWD/a_dat_key"		>>&! new_dbkeys.out
echo "dat $PWD/a.dat"			>>&! new_dbkeys.out
echo "key $PWD/new_a_key"		>>&! new_dbkeys.out
echo "dat $PWD/b.dat"			>>&! new_dbkeys.out
echo "key $PWD/b_dat_key"		>>&! new_dbkeys.out
echo "dat $PWD/b.dat"			>>&! new_dbkeys.out
echo "key $PWD/new_b_key"		>>&! new_dbkeys.out
# Convert the gtm_dbkeys format to libconfig file format.
$gtm_dist/mumps -run CONVDBKEYS new_dbkeys.out new_gtmcrypt.cfg
setenv gtmcrypt_config ./new_gtmcrypt.cfg

$MUPIP create

echo "# Restore into encrypted database file with new key files"
$MUPIP restore mumps.dat old_backup >&! mupip_restore.out
$grep 'RESTORE' mupip_restore.out

echo "dat $PWD/mumps.dat"		>>&! new_dbkeys2.out
echo "key $PWD/new_mumps_key"		>>&! new_dbkeys2.out
echo "dat $PWD/a.dat"			>>&! new_dbkeys2.out
echo "key $PWD/new_a_key"		>>&! new_dbkeys2.out
echo "dat $PWD/b.dat"			>>&! new_dbkeys2.out
echo "key $PWD/new_b_key"		>>&! new_dbkeys2.out
# Convert the gtm_dbkeys format to libconfig file format.
$gtm_dist/mumps -run CONVDBKEYS new_dbkeys2.out new_gtmcrypt2.cfg
setenv gtmcrypt_config ./new_gtmcrypt2.cfg

echo "# Extract to check if globals are accesable"
$MUPIP extract extr1.zwr >&! mupip_extract_extr1.out
if ($status) then
	echo "EXTRACT-E-FAILED. mupip extract on db with new key files failed. check mupip_extract_extr1.out"
endif

setenv gtmcrypt_config ./new_gtmcrypt.cfg

echo "# Loading into encrypted database file with new key files"
$MUPIP load -fo=binary extr.bin >&! mupip_load.out
$grep 'LOAD TOTAL' mupip_load.out

setenv gtmcrypt_config ./new_gtmcrypt2.cfg
echo "# Extract to check if globals are accesable"
$MUPIP extract extr2.zwr >&! mupip_extract_extr2.out
$grep 'TOTAL:' mupip_extract_extr2.out

$gtm_tst/com/dbcheck.csh
