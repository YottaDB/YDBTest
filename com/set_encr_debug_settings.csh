#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2009-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

set cur_dir = `pwd`

# For a test like filter, this file itself will be gzipped for the inner tests.
if (-f ../encrypt_env_settings.csh.gz) then
	gunzip ../encrypt_env_settings.csh.gz >& /dev/null
endif

if (! -f ../encrypt_env_settings.csh) then
	echo "Please source the script from the failed subtest directory. Exiting!"
	exit 1
endif

# Figure out the subtest name from the current dir.
set subtest_name = `basename $cur_dir`

# Source the encryption settings file - encrypt_env_settings.csh. This file will always be in one directory
# up the failed directory. Note that even for a test like filter_3 which will spawn a test within the parent
# test, the encrypt_env_settings.csh of the spawned test should be sourced and not the encrypt_env_settings.csh
# of the parent test.


# Unzip settings.csh as that contains the $gtm_crypt_plugin environment variable that needs to be sourced as well.
if (-f settings.csh.gz) then
	gunzip settings.csh.gz
endif

# Because settings.csh may contain references to $gtm_tst, and we only want to match the encryption library chosen
# in the test, we find the requisite values alone and do not source the entire script.
source ../encrypt_env_settings.csh
if (-f settings.csh) then
	set enc_lib = `awk '/setenv encryption_lib/ {print $3}' settings.csh`			# BYPASSOK
	set enc_algo = `awk '/setenv encryption_algorithm/ {print $3}' settings.csh`		# BYPASSOK
	if ((0 < $#enc_lib) && (0 < $#enc_algo)) then
		setenv gtm_crypt_plugin libgtmcrypt_$enc_lib[$#enc_lib]_$enc_algo[$#enc_algo].so
	else
		set enc_plugin = `awk '/setenv gtm_crypt_plugin/ {print $3}' settings.csh`	# BYPASSOK
		if (0 < $#enc_plugin) then
			setenv gtm_crypt_plugin "$enc_plugin[$#enc_plugin]"
		endif
	endif
endif

# Since it's possible that the user never set the version before running the test so the below
# override of gtm_passwd might not work if the default version that was existing while the test
# was run did not have encryption support at all. So, find out the version with which the test
# was run and use it to override the gtm_passwd environment variable.
if (-f env.txt) then
	set envfile = "env.txt"
else if (-f env_begin.txt) then
	set envfile = "env_begin.txt"
else
	echo "Cannot find either env.txt nor env_begin.txt. Exiting!"
	exit 1
endif

set gtm_tst_ver_used = `awk -F = '/^tst_ver/ {print $2}' $envfile`	#BYPASSOK
set gtm_tst_img_used = `awk -F = '/^tst_image/ {print $2}' $envfile`	#BYPASSOK

echo "------------------------------------"
echo "Setting version to $gtm_tst_ver_used"
echo "------------------------------------"
version $gtm_tst_ver_used $gtm_tst_img_used

# Override the gtm_passwd by computing based on $USER currently logged in. This is done so that user other
# than the one who ran the test initially, could essentially debug it as well.
if ("$USER" != "gtmtest1") then
	set gtm_test_gpghome_passwd = "gtmrocks"
else
	set gtm_test_gpghome_passwd = "gtmtest1"
endif
setenv gtm_passwd `echo $gtm_test_gpghome_passwd | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`

# gunzip all the configuration(s)
find . -name "$gtmcrypt_config.gz" -exec gunzip '{}' \;
find . -name "$gtm_dbkeys.gz" -exec gunzip '{}' \;
# gunzip all the key files
find . -name "*key.gz" -exec gunzip '{}' \;

echo "ENCRYPTION SETUP DONE!"
exit 0
