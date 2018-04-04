#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Play with accessibility and contents of the symmetric keys
# referenced in the encryption configuration file.
#################################################################

set iv = `$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
echo $iv > iv.txt

###################################################################################################################################
# Test case 1.	Keyring with whose public key the symmetric key was encrypted is missing before a certain encryption-enabled
# 		operation relying on that symmetric key is attempted.
###################################################################################################################################

echo "Case 1"

setenv GNUPGHOME_OLD $GNUPGHOME
setenv GNUPGHOME ${GNUPGHOME_OLD}1
cp -r $GNUPGHOME_OLD $GNUPGHOME
cp $gtm_pubkey .
setenv gtm_pubkey `pwd`/pubkey.asc

cat > gtmcrypt-orig.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps_dat_key";
	} );
};
files : {
        mumps:	"$PWD/mumps_dat_key";
};
EOF

# Choose a particular operation to try.
set operation = `$gtm_dist/mumps -run pickOperation1^symkeymanagement`
echo $operation > operation1.txt

# Prepare the environment based on the selected operation.
if ("mupip_create" == $operation) then
	$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde1.out
	setenv gtm_encrypt_notty "--no-permission-warning"
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps_dat_key
	unsetenv gtm_encrypt_notty
	setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
else
	$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate1.out
	$gtm_tst/com/reset_gpg_agent.csh
	rm $gtm_dbkeys
endif

setenv gtmcrypt_config `pwd`/gtmcrypt-orig.cfg

# Remove the keyring (by fingerprint) with which the symmetric key was encrypted.
set fingerprint = `$gpg --homedir=$GNUPGHOME --fingerprint gtm@fnis.com | $head -n 4 | $tst_awk '/Key fingerprint/{sub(/^.*= /,""); gsub(" ","");print $0}'`
$gpg --homedir=$GNUPGHOME --batch --delete-secret-and-public-key "$fingerprint"

# Either try creating a database, or set a global, or try writing to a file.
if ("mupip_create" == $operation) then
	$gtm_dist/mupip create >&! test1.out
	$gtm_tst/com/check_error_exist.csh test1.out YDB-F-DBNOCRE >&! dbnocre1.outx
	$grep -q "seen in test1.out as expected" dbnocre1.outx
	if ($status) then
		echo "TEST-E-FAIL, YDB-F-DBNOCRE is not found in test1.out."
	endif
else if ("db" == $operation) then
	$gtm_dist/mumps -run %XCMD 'set ^a(1)=$horolog' >&! test1.out
	mv mumps.dat mumps.dat.1
	mv mumps.gld mumps.gld.1
else
	$gtm_dist/mumps -run %XCMD 'set x="file1" open x:(newversion:key="mumps '$iv'") use x write "hey",! close x' >&! test1.out
	mv mumps.dat mumps.dat.1
	mv mumps.gld mumps.gld.1
endif

$gtm_tst/com/check_error_exist.csh test1.out YDB-E-CRYPTKEYFETCHFAILED

$gtm_tst/com/reset_gpg_agent.csh
setenv GNUPGHOME $GNUPGHOME_OLD
mv mumps_dat_key mumps_dat_key_1

###################################################################################################################################
# Test case 2.	Keyring with whose public key the symmetric key was encrypted goes missing after a GT.M process is started but
# 		before a certain encryption-enabled operation relying on that symmetric key is attempted.
###################################################################################################################################

echo "Case 2"

setenv GNUPGHOME_OLD $GNUPGHOME
setenv GNUPGHOME ${GNUPGHOME_OLD}2
cp -r $GNUPGHOME_OLD $GNUPGHOME

# Choose a particular operation to try.
set operation = `$gtm_dist/mumps -run pickOperation2^symkeymanagement`
echo $operation > operation2.txt

# Prepare the environment.
$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate2.out
$gtm_tst/com/reset_gpg_agent.csh
rm $gtm_dbkeys
setenv gtmcrypt_config `pwd`/gtmcrypt-orig.cfg

# Prepare a script to remove the keyring (by fingerprint) with which the symmetric key was encrypted.
cat > delete-key.csh << EOF
setenv GNUPGHOME $GNUPGHOME
set fingerprint = \`$gpg --homedir=\$GNUPGHOME --fingerprint gtm@fnis.com | $head -n 4 | $tst_awk '/Key fingerprint/{sub(/^.*= /,""); gsub(" ","");print \$0}'\`
$gpg --homedir=\$GNUPGHOME --batch --delete-secret-and-public-key "\$fingerprint"
$gtm_tst/com/reset_gpg_agent.csh
EOF
chmod 755 delete-key.csh

# Try setting a global or writing to a file.
if ("db" == $operation) then
	$gtm_dist/mumps -run %XCMD 'set ^a(2)=1 zsystem "source delete-key.csh" set ^a(2)=$horolog' >&! test2.out
else
	$gtm_dist/mumps -run %XCMD 'set x="file2",key="mumps '$iv'" open x:(key=key) use x write "hey",! close x zsystem "source delete-key.csh" open x:(newversion:key=key) use x write "you",! close x' >&! test2.out
endif

$gtm_tst/com/reset_gpg_agent.csh
setenv GNUPGHOME $GNUPGHOME_OLD
mv mumps_dat_key mumps_dat_key_2
mv mumps.dat mumps.dat.2
mv mumps.gld mumps.gld.2

###################################################################################################################################
# Test case 3.	Symmetric cipher key is of arbitrary length.
###################################################################################################################################

echo "Case 3"

# Choose a particular operation to try.
set operation = `$gtm_dist/mumps -run pickOperation3^symkeymanagement`
echo $operation > operation3.txt

# Prepare the environment based on the selected operation.
if ("mupip_create" == $operation) then
	$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde3.out
	setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
else
	$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate3.out
	mv mumps_dat_key mumps_dat_key_3_1
	rm $gtm_dbkeys
endif

setenv gtmcrypt_config `pwd`/gtmcrypt-orig.cfg

# Produce a symmetric cipher key of arbitrary length within [1;128].
@ sym_key_len = `$gtm_dist/mumps -run rand 128 1 1`
echo $sym_key_len > sym_key_len3.txt
$gpg --homedir=$GNUPGHOME --gen-random 0 $sym_key_len | $gpg --homedir=$GNUPGHOME --armor --encrypt --default-recipient gtm@fnis.com --comment "gtm" --output mumps_dat_key

# Either try creating a database, or set a global, or try writing to a file.
if ("mupip_create" == $operation) then
	$gtm_dist/mupip create >&! test3.out
else if ("db" == $operation) then
	$gtm_dist/mumps -run %XCMD 'set ^a(3)=$horolog' >&! test3.out
	$gtm_tst/com/check_error_exist.csh test3.out YDB-E-CRYPTKEYFETCHFAILED >&! cryptkeyfetchfailed3.outx
	$grep -q "Expected hash" cryptkeyfetchfailed3.outx
	if ($status) then
		echo "TEST-E-FAIL, YDB-E-CRYPTKEYFETCHFAILED is not found in test3.out."
	endif
else
	$gtm_dist/mumps -run %XCMD 'set x="file3" open x:(newversion:key="mumps '$iv'") use x write "hey",! close x' >&! test3.out
endif

mv mumps_dat_key mumps_dat_key_3_2
mv mumps.dat mumps.dat.3
mv mumps.gld mumps.gld.3

###################################################################################################################################
# Test case 4.	Symmetric cipher key cannot be resolved due to a circular symlink reference.
###################################################################################################################################

echo "Case 4"

# Choose a particular operation to try.
set operation = `$gtm_dist/mumps -run pickOperation4^symkeymanagement`
echo $operation > operation4.txt

# Prepare the environment based on the selected operation.
if ("mupip_create" == $operation) then
	$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde4.out
	setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
	setenv gtm_encrypt_notty "--no-permission-warning"
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps_dat_key
	unsetenv gtm_encrypt_notty
else
	$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate4.out
	rm $gtm_dbkeys
endif

mv mumps_dat_key mumps_dat_key_4_1
setenv gtmcrypt_config `pwd`/gtmcrypt-orig.cfg
ln -s mumps_dat_key_link mumps_dat_key
ln -s mumps_dat_key mumps_dat_key_link

# Either try creating a database, or set a global, or try writing to a file.
if ("mupip_create" == $operation) then
	$gtm_dist/mupip create >&! test4.out
	$gtm_tst/com/check_error_exist.csh test4.out YDB-F-DBNOCRE >&! dbnocre4.outx
	$grep -q "seen in test4.out as expected" dbnocre4.outx
	if ($status) then
		echo "TEST-E-FAIL, YDB-F-DBNOCRE is not found in test4.out."
	endif
else if ("db" == $operation) then
	$gtm_dist/mumps -run %XCMD 'set ^a(4)=$horolog' >&! test4.out
	mv mumps.dat mumps.dat.4
	mv mumps.gld mumps.gld.4
else
	$gtm_dist/mumps -run %XCMD 'set x="file4" open x:(newversion:key="mumps '$iv'") use x write "hey",! close x' >&! test4.out
	mv mumps.dat mumps.dat.4
	mv mumps.gld mumps.gld.4
endif

$gtm_tst/com/check_error_exist.csh test4.out YDB-E-CRYPTKEYFETCHFAILED

rm mumps_dat_key
rm mumps_dat_key_link

###################################################################################################################################
# Test case 5.	Symmetric cipher key is accessed through a regular symlink.
###################################################################################################################################

echo "Case 5"

# Choose a particular operation to try.
set operation = `$gtm_dist/mumps -run pickOperation4^symkeymanagement`
echo $operation > operation5.txt

# Prepare the environment based on the selected operation.
if ("mupip_create" == $operation) then
	$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde5.out
	setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d ' '`
	setenv GTMXC_gpgagent $gtm_dist/plugin/gpgagent.tab
	setenv gtm_encrypt_notty "--no-permission-warning"
	$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps_dat_key
	unsetenv gtm_encrypt_notty
else
	$gtm_tst/com/dbcreate.csh mumps 1 >&! dbcreate5.out
	rm $gtm_dbkeys
endif

mv mumps_dat_key mumps_dat_key_file
ln -s mumps_dat_key_file mumps_dat_key
setenv gtmcrypt_config `pwd`/gtmcrypt-orig.cfg

# Either try creating a database, or set a global, or try writing to a file.
if ("mupip_create" == $operation) then
	$gtm_dist/mupip create >&! test5.out
else if ("db" == $operation) then
	$gtm_dist/mumps -run %XCMD 'set ^a(5)=$horolog' >&! test5.out
else
	$gtm_dist/mumps -run %XCMD 'set x="file5" open x:(newversion:key="mumps '$iv'") use x write "hey",! close x' >&! test5.out
endif

rm mumps_dat_key
mv mumps_dat_key_file mumps_dat_key_5
mv mumps.dat mumps.dat.5
mv mumps.gld mumps.gld.5

# No need to invoke dbcheck here.
