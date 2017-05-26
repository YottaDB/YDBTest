#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

####################################################################################################################
# Test cases to check accessibility of configuration file, obfuscation file, symmetric key file, and keyring file. #
# Checking is done for various scenarios such as if any of the files is missing, empty, unreadable, or invalid.    #
####################################################################################################################

@ count = 100
@ i = 1
@ failed = 0

$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde.out
# We do not go fully random because, when used as an invalid symmetric key file, certain values of the first byte or
# two convince GPG that it is dealing with legitimate encrypted data, which it attempts to decrypt.
$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(2047,"0:1:99")' > randStr
set file = debughelp.txt
setenv gtm_pinentry_log $PWD/local_gtm_pinentry.log
setenv gtm_obfuscation_key $PWD/obf_key
set passwd = $gtm_passwd
###############################
#    Config file changes      #
###############################
alias setMissingConfig '		\\
echo setMissingConfig >> $file;		\\
'
alias setEmptyConfig ' 			\\
echo setEmptyConfig >> $file;		\\
touch gtmcrypt.cfg;			\\
'
alias setUnreadableConfig '		\\
echo setUnreadableConfig >> $file;	\\
cp validGtmcrypt.cfg gtmcrypt.cfg;	\\
chmod a-r gtmcrypt.cfg;			\\
'
alias setInvalidConfig '		\\
echo setInvalidConfig >> $file;		\\
cp randStr gtmcrypt.cfg;		\\
set invalidConfigFlag = 1;		\\
'
alias setValidConfig '			\\
echo setValidConfig >> $file;		\\
cp validGtmcrypt.cfg gtmcrypt.cfg;	\\
'
###############################
#  Obfuscation file changes   #
###############################
alias setMissingObf '			\\
echo setMissingObf >> $file;		\\
'
alias setEmptyObf '			\\
echo setEmptyObf >> $file;		\\
touch obf_key;				\\
'
alias setUnreadableObf '		\\
echo setUnreadableObf >> $file;		\\
cp randStr obf_key;			\\
chmod a-r obf_key;			\\
'
alias setValidObf '			\\
echo setValidObf >> $file;		\\
cp randStr obf_key;			\\
setenv gtm_passwd `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f 3 -d '"' '"'`; \\
'
###############################
#  Symmetric Key file changes #
###############################
alias setMissingSymkey '		\\
echo setMissingSymkey >> $file;		\\
'
alias setEmptySymkey '			\\
echo setEmptySymkey >> $file;		\\
touch mumps.key;			\\
set emptySymkeyFlag = 1;		\\
'
alias setUnreadableSymkey '		\\
echo setUnreadableSymkey >> $file;	\\
cp mumps_key_backup mumps.key;		\\
chmod a-r mumps.key			\\
'
alias setInvalidSymkey '		\\
echo setInvalidSymkey >> $file;		\\
cp randStr mumps.key;			\\
set invalidSymkeyFlag = 1;		\\
'
alias setValidSymkey '			\\
echo setValidSymkey >> $file;		\\
cp mumps_key_backup mumps.key;		\\
'
###############################
#  Keyring file changes       #
###############################

alias setMissingKeyRing '		\\
echo setMissingKeyRing >> $file;	\\
rm -rf $GNUPGHOME/{sec,pub}ring.*; 	\\
'
alias setEmptyKeyRing '			\\
echo "setEmptyKeyRing" >> $file;	\\
rm -rf $GNUPGHOME/{sec,pub}ring.*; 	\\
touch $GNUPGHOME/secring.gpg;		\\
touch $GNUPGHOME/pubring.gpg;		\\
touch $GNUPGHOME/pubring.kbx;		\\
'
alias setUnreadableKeyRing '		\\
echo "setUnreadableKeyRing" >> $file;	\\
chmod a-r $GNUPGHOME/{sec,pub}ring.*;	\\
'
alias setInvalidKeyRing '		\\
echo setInvalidKeyRing >> $file;	\\
cp randStr $GNUPGHOME/secring.gpg;	\\
cp randStr $GNUPGHOME/pubring.gpg;	\\
cp randStr $GNUPGHOME/pubring.kbx;	\\
set invalidKeyringFlag = 1;		\\
'
alias setValidKeyRing '			\\
echo setValidKeyRing >> $file;		\\
'
alias setUnreadableGnupgDir '		\\
echo setUnreadableGnupgDir >> $file;	\\
chmod a-r $GNUPGHOME;			\\
'
# Creating symmetric key file, configuration file and its backup
setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps_key_backup
unsetenv gtm_encrypt_notty
echo "database : { keys : ( { dat: "\""$PWD/mumps.dat"\""; key: "\""$PWD/mumps.key"\""; } ); };" > validGtmcrypt.cfg

while ($i <= $count)
	set invalidSymkeyFlag	= 0
	set invalidKeyringFlag	= 0
	set invalidConfigFlag	= 0
	set emptySymkeyFlag	= 0
	set varSymkeyFlag	= 0

	setenv gtm_passwd $passwd
	# Creating copy of GNUPGHOME
	setenv GNUPGHOME_OLD $GNUPGHOME
	setenv GNUPGHOME ${GNUPGHOME_OLD}2
	cp -r $GNUPGHOME_OLD $GNUPGHOME

	echo "=========> TEST $i <===========" >> $file

	set gnupgOption=`$gtm_dist/mumps -run %XCMD 'write $random(6)'`
	if ($gnupgOption == 0) then
		setMissingKeyRing
	else if ($gnupgOption == 1) then
		setEmptyKeyRing
	else if ($gnupgOption == 2) then
		setUnreadableKeyRing;
	else if ($gnupgOption == 3) then
		setInvalidKeyRing
	else if ($gnupgOption == 4) then
		setValidKeyRing
	else if ($gnupgOption == 5) then
		setUnreadableGnupgDir
	endif

	set configOption = `$gtm_dist/mumps -run %XCMD 'write $random(5)'`
	if ($configOption == 0) then
		setMissingConfig
	else if ($configOption == 1) then
		setEmptyConfig
	else if ($configOption == 2) then
		setUnreadableConfig
	else if ($configOption == 3) then
		setInvalidConfig
	else if ($configOption == 4) then
		setValidConfig
	endif

	set obfOption=`$gtm_dist/mumps -run %XCMD 'write $random(4)'`
	if ($obfOption == 0) then
		setMissingObf
	else if ($obfOption == 1) then
		setEmptyObf
	else if ($obfOption == 2) then
		setUnreadableObf
	else if ($obfOption == 3) then
		setValidObf
	endif

	set symkeyOption=`$gtm_dist/mumps -run %XCMD 'write $random(5)'`
	if ($symkeyOption == 0) then
		setMissingSymkey
	else if ($symkeyOption == 1) then
		setEmptySymkey
	else if ($symkeyOption == 2) then
		setUnreadableSymkey
	else if ($symkeyOption == 3) then
		setInvalidSymkey
	else if ($symkeyOption == 4) then
		setValidSymkey
	endif

	source $gtm_tst/$tst/u_inref/file_access_checker.csh out${i}.txt $invalidSymkeyFlag $invalidKeyringFlag $invalidConfigFlag $emptySymkeyFlag

	$gtm_dist/mupip create >&! log${i}.txt
	$gtm_tst/com/reset_gpg_agent.csh

	set printed = `$head -n 1 log${i}.txt`
	set expected = `cat out${i}.txt`

	set tempPrinted = `echo $printed | sed 's/line# [0-9]*/line# LINUM/'`
	set printed = "$tempPrinted"

	if ($invalidSymkeyFlag == 1) then
		if ("$printed" =~ "*mumps.key found to be empty*" && "$expected" =~ "*mumps.key: No data*") then
			set varSymkeyFlag = 1
			echo "Diff error msg accepted for invalid sym key" >> $file
		endif
	else if ($emptySymkeyFlag == 1) then
		if ("$printed" =~ "*mumps.key: System error*" && "$expected" =~ "*mumps.key: No data*") then
 			set varSymkeyFlag = 1
			echo "Diff error msg accepted for empty sym key" >> $file
		endif
	endif

	chmod a+r $GNUPGHOME mumps.key gtmcrypt.cfg obf_key >&! /dev/null
	\rm -rf mumps.dat

	if (("$printed" !~ "*${expected}*") && ($varSymkeyFlag == 0)) then
		echo
		echo "TEST-E-FAIL, Test case $i failed. Compare log${i}.txt and out${i}.txt."
		mv mumps.key mumps.key_test${i} >&! /dev/null
		mv gtmcrypt.cfg gtmcrypt.cfg_test${i} >&! /dev/null
		mv obf_key obf_key_test${i} >&! /dev/null
		mv $GNUPGHOME ${GNUPGHOME}_test${i}
		ls -liart ${GNUPGHOME}_test${i}
		$psuser | $grep gpg.agent
		echo
		@ failed = 1
	else
		echo "TEST-$i-PASS." >> $file
		\rm -rf mumps.key gtmcrypt.cfg obf_key $GNUPGHOME
	endif

	@ i = $i + 1
        setenv GNUPGHOME $GNUPGHOME_OLD
end

if (0 == $failed) then
	echo "TEST-I-PASS, Test passed."
endif
