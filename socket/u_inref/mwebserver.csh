#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2015-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2019-2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo ENTERING mwebserver TLS Socket test
# mwebserver test uses modules from https://github.com/shabiel/M-Web-Server
# Specifically VPRJREQ.m (modified) VPRJRSP.m VPRJRUT.m _WHOME.m
# See LICENSE.M-Web-Server
# No claim of copyright is made for the VPRJREQ.m changes.
# Those changes needed to successfully enable TLS were sent to
# Sam Habiel in email on 2015/7/2.  Other changes were made to
# log additional information which may be useful when analyzing
# test failures.
#

# Curl expects valid host names in certificates so generate some

set SH = "/bin/sh"
if ("$HOSTOS" == "SunOS") set SH = "/usr/xpg4/bin/sh"

# On certain platforms, ``openssl'' is found in /usr/local/ssl/bin. So, add that to the path as well.
# The version of OpenSSL in /usr/local/ssl is no longer used on AIX or Solaris systems
if ("$HOSTOS" == "Linux") setenv PATH /usr/local/ssl/bin:${PATH}

# On certain platforms, 'dir' configuration variable in OpenSSL's configuration file is set to a directory that is not writable
# by non-root users. So, take a local copy of the configuration file and adjust the 'dir' configuration variable to './demoCA'
# so that we can create certificates at will.
set config_file = `openssl ca |& $tst_awk '{print $NF; exit}'`
sed 's/^dir.*/dir = .\/demoCA/' $config_file >&! openssl.cnf

# First generate rootca and server certificates.
# Generate rootca.
set subj = "/C=US/ST=PA/L=Malvern/O=YottaDB LLC/OU=Certificate Authority/CN=$HOST/emailAddress=ydbtest@yottadb.com"
$SH $gtm_tst/com/gencert.sh CA --config ./openssl.cnf --out rootca.pem --days 365 --keysize 4096 --pass ydbrocks --subj "$subj"	\
												--self-sign >&! rootca.log
if ($status) then
	echo "Failed to generate rootca certificate. See rootca.log. Exiting.."
	exit -1
endif

set rand = `$gtm_tst/com/genrandnumbers.csh 1 0 1`      # choose 1 random number between 0 and 1 (both included)
if (0 == $rand) then
	# Test server certificates with key password
	set keypass = "--pass ydbrocks"
else
	# Test server certificates with no key password (YDB#377)
	set keypass = ""
endif

# Generate server certificate (signed by rootca)
set subj = "/C=US/ST=PA/L=Malvern/O=YottaDB LLC/OU=GT.M/CN=$HOST/emailAddress=ydbtest@yottadb.com"
$SH $gtm_tst/com/gencert.sh CERT --config ./openssl.cnf --out server.pem --days 365 --keysize 4096 \
					--subj "$subj" --signca rootca.pem --signpass ydbrocks	>&! server-cert.log
if ($status) then
	echo "Failed to generate server certificate. See server-cert.log. Exiting"
	exit -1
endif

setenv gtmcrypt_config `pwd`/config.cfg
cat << EOF >&! $gtmcrypt_config
tls: {
	verify-depth: 7;
	CAfile: "$PWD/demoCA/rootca.pem";
	# crl: "$PWD/gtm.crl";
	# dh512: "$gtm_tst/com/tls/dh512.pem";
	# dh1024: "$gtm_tst/com/tls/dh1024.pem";
	# ssl-options: "SSL_OP_CIPHER_SERVER_PREFERENCE" ;	# tlsssloptions
	# verify-level: "!CHECK";				# tlsverifylevel

	server: {
		# verify-mode: "SSL_VERIFY_PEER";	# goodverifymode
		# verify-level: "CHECK";		# serververifylevel
		format: "PEM";
		cert: "$PWD/demoCA/server.pem";		# servercert
		key: "$PWD/demoCA/private/server.key";	# serverkey
		# session-id-hex: "123456abcdef";	# serversessionid
		# CAfile: "$PWD/calist.pem";		# serverCAfile
	};
};

database: {
	keys: ( {
		dat: "mumps.dat";
		key: "mumps_dat_key";
	} );
};
EOF

setenv gtmgbldir mumps.gld
$gtm_tst/com/dbcreate.csh mumps
source $gtm_tst/com/portno_acquire.csh >>& portno.out

if ("" == "$keypass") then
	# If key was generated without password, unset corresponding env var too.
	source $gtm_tst/com/unset_ydb_env_var.csh ydb_tls_passwd_server gtmtls_passwd_server
endif

$GTM << EOF
SET ^VPRHTTP(0,"port")=$portno
h
EOF
# compile VPR* first since they contain invalid GT.M statements
$gtm_dist/mumps $gtm_tst/$tst/inref/VPRJREQ.m >&! VPRJREQ.outx
$gtm_dist/mumps $gtm_tst/$tst/inref/VPRJRUT.m >&! VPRJRUT.outx
$gtm_dist/mumps $gtm_tst/$tst/inref/VPRJRSP.m >&! VPRJRSP.outx
# start web server in background
$gtm_dist/mumps -run VPRJREQ
# ping the server from M and curl if available
$GTM << EOF
DO ^mwebserver($portno,"$HOST")
h
EOF

sleep 5
$gtm_tst/com/dbcheck.csh -extract mumps
$gtm_tst/com/portno_release.csh
echo LEAVING mwebserver TLS Socket test
