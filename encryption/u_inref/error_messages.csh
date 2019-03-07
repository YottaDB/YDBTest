#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information		#
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
#
# Test different error messages from encryption plugin with respect to gtmcrypt_config and gtm_passwd.
#
setenv gtm_test_spanreg 0	# because this test creates databases with integ errors, gensprgde.m will not work easily
				# since this test creates only a few nodes anyway, disable .sprgde file generation.

# Set white box testing environment to avoid assert failures due to bad encryption configuration.
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 22
#
$gtm_tst/com/dbcreate.csh mumps 3

echo
echo "###################################"
echo "Test case 1: ydb_crypt_config/gtmcrypt_config unset."
echo "###################################"
source $gtm_tst/com/unset_ydb_env_var.csh ydb_crypt_config gtmcrypt_config
\rm -rf *.dat
$MUPIP create
echo

echo
echo "################################################"
echo "Test case 2: ydb_crypt_config/gtmcrypt_config set to null string."
echo "################################################"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_crypt_config gtmcrypt_config
\rm -rf *.dat
$MUPIP create
echo

echo
echo "###########################################################"
echo "Test case 3: ydb_crypt_config/gtmcrypt_config pointing to non-existent file."
echo "###########################################################"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_crypt_config gtmcrypt_config ./nonexistent.cfg
\rm -rf *.dat
$MUPIP create
echo

echo
echo "##############################"
echo "Test case 4: gtm_passwd unset."
echo "##############################"
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_crypt_config gtmcrypt_config ./gtmcrypt.cfg
\rm -rf *.dat
setenv passwd $gtm_passwd
unsetenv gtm_passwd
$MUPIP create
echo

echo
echo "############################################"
echo "Test case 5: gtm_passwd set to empty string."
echo "############################################"
setenv gtm_passwd
\rm -rf *.dat
$MUPIP create
echo

echo
echo "##############################################"
echo "Test case 6: gtm_passwd set to bad passphrase."
echo "##############################################"
setenv gtm_passwd `echo 'badvalue' | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
$gtm_tst/com/reset_gpg_agent.csh
\rm -rf *.dat
$MUPIP create
echo

echo
echo "###########################################"
echo "Test case 7: Encryption key file not found."
echo "###########################################"
setenv gtm_passwd $passwd
$gtm_tst/com/reset_gpg_agent.csh
mv mumps_dat_key key
\rm -rf *.dat
$MUPIP create -reg=DEFAULT
echo

echo
echo "############################################################################"
echo "Test case 8: Configuration file doesn't have an entry for the DEFAULT region."
echo "############################################################################"
cp key mumps_dat_key
\rm -rf *.dat
touch restrict.cfg
$gtm_tst/com/modconfig.csh restrict.cfg append-keypair $PWD/a.dat $PWD/a_dat_key
$gtm_tst/com/modconfig.csh restrict.cfg append-keypair $PWD/b.dat $PWD/b_dat_key
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_crypt_config gtmcrypt_config restrict.cfg
$MUPIP create -reg=DEFAULT
echo

echo
echo "###########################################"
echo "Test case 9: Corrupted encryption key file."
echo "###########################################"
$gt_cc_compiler $gtm_tst/encryption/inref/corrupt_file.c -o corrupt >& compilation.out
cp a_dat_key a_dat_key.bak
rm -f *.dat
./corrupt a_dat_key 140
source $gtm_tst/com/set_ydb_env_var_random.csh ydb_crypt_config gtmcrypt_config ./gtmcrypt.cfg
$MUPIP create -reg=AREG
echo

# Restore back to how it was.
mv a_dat_key.bak a_dat_key
rm -f *.dat
$MUPIP create

$gtm_tst/com/dbcheck.csh
