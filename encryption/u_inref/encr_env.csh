#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Ensure that the generated environment variable configurations
# are treated in the expected way by GT.M.
#################################################################

@ count = 100
@ i = 1

$gtm_dist/mumps -run GDE change -seg DEFAULT -encr >&! gde.out

@ failed = 0
unsetenv gtm_passwd
unsetenv GTMXC_gpgagent
unsetenv gtm_obfuscation_key
unsetenv gtm_crypt_plugin
unsetenv gtmcrypt_config

cat > gtmcrypt.cfg << EOF
database : {
	keys : ( {
		dat: "$PWD/mumps.dat";
		key: "$PWD/mumps.key";
	} );
};
EOF

setenv gtm_encrypt_notty "--no-permission-warning"
$gtm_tst_ver_gtmcrypt_dir/gen_sym_key.sh 0 mumps.key
unsetenv gtm_encrypt_notty

# This is set so that reset_gpg_agent.csh would not fail trying to refer to '~'.
setenv HOMEDIR $HOME

# This allows encrenv.m to pick a valid $GNUPGHOME path pointing to the encryption test's gpg copy.
setenv GNUPGHOMEDIR $GNUPGHOME
$gtm_tst/com/reset_gpg_agent.csh

while ($i <= $count)
	echo "Test case $i" >> mumps.out
	$gtm_dist/mumps -run encrenv env${i}.csh out${i}.txt >>&! mumps.out

	source env${i}.csh
	$gtm_dist/mupip create >&! log${i}.txt
	$gtm_tst/com/reset_gpg_agent.csh

	unsetenv gtm_passwd
	unsetenv GTMXC_gpgagent
	unsetenv gtm_obfuscation_key
	unsetenv GNUPGHOME
	unsetenv gtm_crypt_plugin
	unsetenv gtmcrypt_config
	setenv HOME $HOMEDIR

	set printed = `$head -n 1 log${i}.txt`
	set expected = `cat out${i}.txt`
	if ("$printed" !~ "*${expected}*") then
		echo
		echo "TEST-E-FAIL, Test case $i failed. Compare log${i}.txt and out${i}.txt."
		echo
		@ failed = 1
	endif

	rm -rf mumps.dat >&! /dev/null
	@ i = $i + 1
end

if (0 == $failed) then
	echo "TEST-I-PASS, Test passed."
endif
