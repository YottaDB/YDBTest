#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This subtest is a test for gen_keypair.sh in plugin/gtmcrypt
# All the other plugin scripts are tested either by the basic encryption setup or by hash_verification subtest

echo "#### Test 1 - import_and_sign_key.sh ####"
$gtm_tst/$tst/u_inref/other_user.csh >&! other_user.log
$grep -q "gtm@fnis.com" after_import_list_keys.out
set stat1 = $status
$grep -q "Successfully signed" import_and_sign.out
set stat2 = $status
if ($stat1 || $stat2) then
	echo "Test 1 : Failed - Key not successfully signed and/or imported. Please see import_and_sign.out"
else
	echo "Test 1 : Passed"
endif

$echoline
echo "#### Test 2 - gen_keypair.sh ####"
setenv GNUPGHOME /tmp/__${USER}_$gtm_tst_out
echo "rm -rf $GNUPGHOME"							>> $tst_general_dir/cleanup.csh
setenv gtm_pubkey $GNUPGHOME/$USER@fnis.com_pubkey.txt
if (-d $GNUPGHOME) then
	echo "TEST-E-FAILED: $GNUPGHOME already exists. Exiting.."
	exit 1
endif
echo "# Create a new public/private key-pair"
$gtm_tst/$tst/u_inref/call_gen_keypair.csh
echo "# Verify that the key-pair is usable by creating an encrypted database"
setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
setenv gtm_passwd `echo $USER | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
$gtm_tst/com/dbcreate.csh mumps 1
echo "# From dse dump output, check if the database is encrypted"
$DSE dump -file -all >&! dse_dump_file_all.out
$grep "Database file encrypted" dse_dump_file_all.out |& $grep "TRUE"
if (! $status) then
	echo "TEST-I-PASS : Database file is encrypted as expected"
else
	echo "TEST-E-FAIL : Database file is NOT encrypted"
endif
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/reset_gpg_agent.csh
