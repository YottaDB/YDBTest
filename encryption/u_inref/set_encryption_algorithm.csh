#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

#################################################################
# Helper script to randomly select the encryption algorithm and
# produce the hexadecimal representation of the supplied key
# and IV for further validation using OpenSSL.
#################################################################

set opensslver = `openssl version | $tst_awk -F '[ .]' '{ printf "%d%02d%s",$2,$3,$4}'`
set options = 3
if ( `expr "$opensslver" \>= "1001h"` ) then
	# from version 1.0.1h, OpenSSL added a check on the length for the Blowfish cipher.
	# The current key size (256 bits) is longer than the keysize Blowfish and RC5 algorithms use (128 bits)
	# One solution is to reduce the key size in plugin/gtmcrypt/gen_sym_key.sh, which we don't want to.
	# The other solution is to not pick BLOWFISHCFB/bf-cfb algorithm below, which is what this check does
	# Note 1 : It is possible that some distributions removed this check later
	# Note 2 : It is also possible that the check might be backported to earlier versions too (- in case this test fails on servers with older openssl)
	set options = 2
endif
@ gtm_crypt_plugin_choice = `$gtm_dist/mumps -run rand $options 1 1`
if (1 == $gtm_crypt_plugin_choice) then
	setenv gtm_crypt_plugin libgtmcrypt_gcrypt_AES256CFB.so
	setenv algorithm aes-256-cfb
else if (2 == $gtm_crypt_plugin_choice) then
	setenv gtm_crypt_plugin libgtmcrypt_openssl_AES256CFB.so
	setenv algorithm aes-256-cfb
else
	setenv gtm_crypt_plugin libgtmcrypt_openssl_BLOWFISHCFB.so
	setenv algorithm bf-cfb
endif
echo $gtm_crypt_plugin >> gtm_crypt_plugin.txt
echo $algorithm >> algorithm.txt

cat > parse.m <<EOF
parse
	for  read line quit:\$zeof  set line=\$\$FUNC^%TRIM(line) do:(\$length(line))
	.	set length=\$length(line," ")
	.	for i=1:1:length do
	.	.	set arg=\$piece(line," ",i)
	.	.	set:(1=\$length(arg)) arg="0"_arg
	.	.	write arg
	quit
EOF

setenv ivHex `echo $iv | od -t x1 | $head -n 1 | cut -c 9- | $gtm_exe/mumps -run parse`
echo $ivHex > iv_hex.txt

(echo $password | $gpg --homedir=$GNUPGHOME --batch --passphrase-fd 0 -d mumps.key | od -t x1 | cut -c 9- | $gtm_exe/mumps -run parse > key_hex.txt) >&! /dev/null
setenv keyHex `cat key_hex.txt`
