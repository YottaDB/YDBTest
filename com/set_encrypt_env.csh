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
# This script will set all the encryption related environment variables. If needed, it will create a
# new GnuPG home directory
# Usage :
# $1  -  Output directory where encrypt_env_settings.{csh,txt} should be created
# $2  -  Value of $gtm_dist. Since this script is invoked via ssh in case of multi-host tests, $gtm_dist
#	 need not be defined always
# $3  -  Value of test version used

set shorthost = ${HOST:ar}

set out_dir="$1"
setenv gtm_dist 		"$2"
setenv gtm_tst 			$gtm_test/$3
setenv gtm_tools 		${gtm_dist:h}/tools

set outfile="$out_dir/encrypt_env_settings.txt"

# If encryption environment is already setup, then exit
if ( (-e $out_dir/encrypt_env_settings.csh) && (! $?encrypt_env_rerun)) then
	exit 0
endif

mkdir -p $out_dir >& /dev/null
source $gtm_tst/com/set_specific.csh

if ($USER == "gtmtest1") then
	setenv gtm_test_gpghome_passwd $USER
	setenv gtm_test_gpghome_uid $USER
else
	setenv gtm_test_gpghome_passwd "gtmrocks"
	setenv gtm_test_gpghome_uid "gtm"
endif

# Find if the GT.M version supports encryption
if ( "TRUE" != "`$gtm_tst/com/is_encrypt_support.csh ${gtm_dist:h:t} ${gtm_dist:t}`" ) then
	echo "test_encryption=NON_ENCRYPT" > $outfile
	setenv test_encryption "NON_ENCRYPT"
else
	echo "gpg=$gpg" > $outfile

	setenv gtm_gpg_exact_version `$gpg --version | $tst_awk '/gpg/ {print $3}' | $tst_awk -F '.' '{printf "%d%02d%02d",$1,$2,$3}'`
	echo "gtm_gpg_exact_version=$gtm_gpg_exact_version" >> $outfile
	if (($gtm_gpg_exact_version >= 30000) || ($gtm_gpg_exact_version < 10000)) then
		echo "TEST-E-GPGVERSION : GnuPG version should be either 1.x.x or 2.x.x, but found to be $gtm_gpg_exact_version"
	endif

	setenv gtm_tst_ver_gtmcrypt_dir $gtm_dist/plugin/gtmcrypt
	echo "gtm_tst_ver_gtmcrypt_dir=$gtm_tst_ver_gtmcrypt_dir" >> $outfile

	echo "gtm_tst=$gtm_tst" >> $outfile

	setenv user_emailid $gtm_test_gpghome_uid
	echo "user_emailid=$gtm_test_gpghome_uid" >> $outfile

	# Encryption environment needs to be set up
	setenv GNUPGHOME "/tmp/gnupgdir/$USER"
	echo "GNUPGHOME=$GNUPGHOME" >> $outfile

	setenv gtm_pinentry_log "$GNUPGHOME/gtm_pinentry.log"
	echo "gtm_pinentry_log=$gtm_pinentry_log" >> $outfile

	setenv gtm_pubkey "$GNUPGHOME/gtm@fnis.com_pubkey.txt"
	echo "gtm_pubkey=$gtm_pubkey" >> $outfile

	if ((! -d $GNUPGHOME) || (! -f $gtm_pubkey)) then
		echo "TEST-E-NOKEY, Either $GNUPGHOME or $gtm_pubkey does not exist. Turning off encryption."
		echo "Please, resubmit the test without encryption using -noencrypt or ensure that /tmp/gnupgdir/$USER is set up"
		echo "  correctly as a copy of $gtm_com/gnupg, which, in turn, should contain the proper files produced by the"
		echo "  $cms_tools/build_gnupghome.csh script."
		setenv test_encryption "NON_ENCRYPT"
		exit
	endif

	# Setup library paths
	source $gtm_tst/com/set_ldlibpath.csh

	# Note that it depends on the version of gpg, not gpg2, whether gpg-agent is used to retrieve passphrases.
	set gtm_old_gpg_exact_version = `gpg --no-permission-warning --version | $tst_awk '/gpg/ {print $3}' | $tst_awk -F '.' '{printf "%d%02d%02d",$1,$2,$3}'`
	# The below script had to kill a running gpg-agent, which causes test failures. Rely on the presence or absence of gpg-agent instead
	# i.e if gpg-agent does not exist OR if gpg version is older than 1.4.16, gpg does NOT use agent i.e set gtm_gpg_use_agent to 0
	#$gtm_tst/com/is_gpg_agent.csh < /dev/null >>&! gpg_agent_check.out
	which gpg-agent >&! /dev/null
	set isagent = $status
	# rajamanin and base has gpg version 1.4.11. Though `which gpg-agent` returns 0 (meaning gpg-agent is present) gpg 1.4.11 does not use agent.
	# Ignore the return status if gpg version is older than 1.4.16 and force gtm_gpg_use_agent to 0
	if ( (1 == $isagent) || (10416 > $gtm_old_gpg_exact_version)) then
		setenv gtm_gpg_use_agent 0
	else
		setenv gtm_gpg_use_agent 1
	endif
	echo "gtm_gpg_use_agent=$gtm_gpg_use_agent" >> $outfile


	setenv gtm_passwd `echo "$gtm_test_gpghome_passwd" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	echo "gtm_passwd=$gtm_passwd" >> $outfile

	setenv gtm_db_mapping_file db_mapping_file
	echo "gtm_db_mapping_file=$gtm_db_mapping_file" >> $outfile

	setenv gtm_dbkeys $gtm_db_mapping_file
	echo "gtm_dbkeys=$gtm_dbkeys" >> $outfile

	setenv gtmcrypt_config gtmcrypt.cfg
	echo "gtmcrypt_config=$gtmcrypt_config" >> $outfile

	setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
	echo "GTMXC_gpgagent=$gtm_dist/plugin/gpgagent.tab" >> $outfile

	echo "LIBPATH=$LIBPATH" >> $outfile
	echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH" >> $outfile

	setenv gpg_ignore_str "gpg"
	echo "gpg_ignore_str=$gpg_ignore_str" >> $outfile

	unsetenv GPG_AGENT_INFO
	echo "GPG_AGENT_INFO=" >> $outfile
endif

# Generate encrypt_env_settings.csh file
sed 's/^/setenv /;s/=/ "/;s/$/"/' $outfile >&! $out_dir/encrypt_env_settings.csh

# Instructions to set up encryption environment while debugging
cat > $out_dir/encrypt_debug_README << cat_EOF
The test failed in an encryption environment. Do the below from the failed subtest dir to setup encryption environment.
source $gtm_tst/com/set_encr_debug_settings.csh
cat_EOF
