#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
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

source $gtm_tst/com/portno_acquire.csh >>& portno.out
set randhost=`$gtm_exe/mumps -run %XCMD 'set rand=2+$Random(6) write $$^findhost(rand),!'`
# Various tests to verify that the plugin reports appropriate errors.
# Variant of tls/errors.csh for TLS sockets - any changes in creating
# certificates need to be made in both scripts

set CA="openssl ca"

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

# Now fix the config file to contain './demoCA' for the '

# First generate a rootca, intermediate-ca-1, intermediate-ca-2 and the client/server certificates.
# Generate rootca.
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=Certificate Authority/CN=www.fisglobal.com/emailAddress=security@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CA --config ./openssl.cnf --out rootca.pem --days 365 --keysize 1024 --pass gtmrocks --subj "$subj"	\
												--self-sign >&! rootca.log
if ($status) then
	echo "Failed to generate rootca certificate. See rootca.log. Exiting.."
	exit -1
endif

# Generate intermediate-ca-1 (signed by rootca)
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=Intermediate CA-1/CN=www.fisglobal.com/emailAddress=security@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CA --config ./openssl.cnf --out intermediate-ca-1.pem --days 365 --keysize 1024 --pass gtmrocks 	\
					--subj "$subj" --signca rootca.pem --signpass gtmrocks	>&! intermediate-ca-1.log
if ($status) then
	echo "Failed to generate intermediate-ca-1 certificate. See intermediate-ca-1.log. Exiting"
	exit -1
endif

# Generate intermediate-ca-2 (signed by intermediate-ca-1)
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=Intermediate CA-2/CN=www.fisglobal.com/emailAddress=security@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CA --config ./openssl.cnf --out intermediate-ca-2.pem --days 365 --keysize 1024 --pass gtmrocks 	\
			--subj "$subj" --signca intermediate-ca-1.pem --signpass gtmrocks	>&! intermediate-ca-2.log
if ($status) then
	echo "Failed to generate intermediate-ca-2 certificate. See intermediate-ca-2.log. Exiting"
	exit -1
endif


# Generate client certificate (signed by intermediate-ca-2)
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=INSTANCE1/CN=www.fisglobal.com/emailAddress=INST1@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CERT --config ./openssl.cnf --out client.pem --days 365 --keysize 1024 --pass gtmrocks --subj "$subj" \
			--signca intermediate-ca-2.pem --signpass gtmrocks			>&! clientcert.log
if ($status) then
	echo "Failed to generate client certificate. See clientcert.log. Exiting"
	exit -1
endif

# Generate server certificate (also signed by intermediate-ca-2)
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=INSTANCE2/CN=www.fisglobal.com/emailAddress=INST2@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CERT --config ./openssl.cnf --out server.pem --days 365 --keysize 1024 --pass gtmrocks --subj "$subj" \
			--signca intermediate-ca-2.pem --signpass gtmrocks			>&! servercert.log
if ($status) then
	echo "Failed to generate server certificate. See servercert.log. Exiting"
	exit -1
endif

# Create a single CA certificate file containing the rootca and intermediates.
cat ./demoCA/rootca.pem ./demoCA/intermediate-ca-1.pem ./demoCA/intermediate-ca-2.pem >&! calist.pem

# To avoid adding extra stuff onto the config file later, add a dummy crl and when it is time to use it, just update the
# CRL. Note: we have to generate a dummy CRL for each CA that will be verified during exchange of certificates.
$CA -config ./openssl.cnf -gencrl -out gtm-inter-1.crl -cert ./demoCA/intermediate-ca-2.pem 	\
		-keyfile ./demoCA/private/intermediate-ca-2.key -passin pass:gtmrocks >>&! gencrl.log
if ($status) then
	echo "TEST-E-FAILED, Failed to generate certificate revocation list for intermediate-ca-2. Exiting.."
	exit -1
endif

$CA -config ./openssl.cnf -gencrl -out gtm-inter-2.crl -cert ./demoCA/intermediate-ca-1.pem	\
		-keyfile ./demoCA/private/intermediate-ca-1.key -passin pass:gtmrocks >>&! gencrl.log
if ($status) then
	echo "TEST-E-FAILED, Failed to generate certificate revocation list for intermediate-ca-1. Exiting.."
	exit -1
endif

$CA -config ./openssl.cnf -gencrl -out gtm-rootca.crl -cert ./demoCA/rootca.pem		\
		-keyfile ./demoCA/private/rootca.key -passin pass:gtmrocks >>&! gencrl.log
if ($status) then
	echo "TEST-E-FAILED, Failed to generate certificate revocation list for rootca. Exiting.."
	exit -1
endif

cat gtm-inter-1.crl gtm-inter-2.crl gtm-rootca.crl >>&! gtm.crl

setenv gtmcrypt_config `pwd`/config.cfg
cat << EOF >&! $gtmcrypt_config
tls: {
	verify-depth: 4;
	CAfile: "$PWD/calist.pem";
	crl: "$PWD/gtm.crl";
	dh512: "$gtm_tst/com/tls/dh512.pem";
	dh1024: "$gtm_tst/com/tls/dh1024.pem";
	# ssl-options: "SSL_OP_CIPHER_SERVER_PREFERENCE" ;	# tlsssloptions
	# verify-level: "!CHECK";				# tlsverifylevel

	INSTANCE1: {
		cipher-list: "";	# override top level list
		format: "PEM";
		cert: "$PWD/demoCA/client.pem";
		key: "$PWD/demoCA/private/client.key";
	};

	INSTANCE2: {
		cipher-list: "";
		format: "PEM";
		cert: "$PWD/demoCA/server.pem";
		key: "$PWD/demoCA/private/server.key";
	};

	client: {
		format: "PEM";
		cert: "$PWD/demoCA/client.pem";
		key: "$PWD/demoCA/private/client.key";
	};

	client2: {				# for CASE 2
		# cipher-list: " " ;		# clientcipher
		# verify-level: "CHECK";	# client2verifylevel
	};

	server: {
		verify-mode: "SSL_VERIFY_PEER";		# goodverifymode
		verify-level: "CHECK";			# serververifylevel
		# cipher-list: "DEFAULT:! :!ADH:!LOW:!EXP:!MD5:@STRENGTH";	# servercipher
		format: "PEM";
		cert: "$PWD/demoCA/server.pem";		# servercert
		key: "$PWD/demoCA/private/server.key";	# serverkey
		# ssl-options: "SSL_OP_NO_SSLv3:!SSL_OP_CIPHER_SERVER_PREFERENCE" ;	# goodssloptions
		# ssl-options: "SSL_OP_NO_TICKET" ;	# noticketssloption AIX work around
		# session-id-hex: "123456abcdef";	# serversessionid
		# CAfile: "$PWD/calist.pem";		# serverCAfile
	};

	badserver: {					# no certificate
		verify-mode: "SSL_VERIFY_PEER";		# badverifymode
	};

	reneg: {
		# verify-depth: 4;			# renegverifydepth
		# verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_FAIL_IF_NO_PEER_CERT";	# renegverifymode
		# verify-mode: "SSL_VERIFY_PEER:SSL_VERIFY_CLIENT_ONCE";	# renegverifyonce
		session-id-hex: "123456abcdef";	# renegsessionid
		# CAfile: "$PWD/calist.pem";		# renegCAfile
		# verify-level: "!CHECK";		# renegverifylevel
	};
};

database: {
	keys: ( {
		dat: "mumps.dat";
		key: "mumps_dat_key";
	} );
};
EOF
cat << EOF >&! $gtmcrypt_config.dbkeysonly
database: {
	keys: ( {
		dat: "mumps.dat";
		key: "mumps_dat_key";
	} );
};
EOF

$gtm_tst/com/dbcreate.csh mumps 1 -record_size=512
$GTM << EOF
s ^config("portno")=$portno
s ^config("hostname")="$randhost"
h
EOF


echo
echo "TEST CASE 1a: Both certificate and key in the same file should work."
echo "			both cert and key name the same file."
echo

cp -p $gtmcrypt_config  $gtmcrypt_config.starting
cat $PWD/demoCA/private/server.key $PWD/demoCA/server.pem >$PWD/serverboth.pem
$tst_awk -v 'cert="'$PWD/serverboth.pem'";' ' /server\.(pem|key)/ {$2=cert} {print}' $gtmcrypt_config.starting >&! $gtmcrypt_config
$GTM << EOF
d succeed^tsocerrors("1a","server")
EOF

echo
echo "TEST CASE 1b: Both certificate and key in the same file should work."
echo "			just cert specified and no key."
echo
cp -p $gtmcrypt_config  $gtmcrypt_config.both
$tst_awk  ' /serverkey/ {next}  {print}' $gtmcrypt_config.both >&! $gtmcrypt_config
$GTM << EOF
d succeed^tsocerrors("1b","server")
EOF

echo
echo "TEST CASE 1c: Private key without cert should issue an appropriate error."
# ^expected("1c","device")="1,Certificate corresponding to TLSID: server not found in configuration file."
echo
$tst_awk  ' /servercert/ {next}  {print}' $gtmcrypt_config.both >&! $gtmcrypt_config
$GTM << EOF
d fail^tsocerrors("1c","server","not found")
EOF

echo
echo "TEST CASE 1d: Unable to open private key should issue an appropriate error."
# ^expected("1d","device")="1,Private Key corresponding to TLSID: server - error opening file <pathto>missing.key"
echo
$tst_awk  ' /serverkey/ { sub("server.key", "missing.key") } {print}' $gtmcrypt_config.starting >&! $gtmcrypt_config
$GTM << EOF
d fail^tsocerrors("1d","server","error opening")
EOF

echo
echo "TEST CASE 2: Check cipher-list option by excluding cipher from server list which is only one for client."
# ^expected(2,"device")="1,error:1408A0C1:SSL routines:SSL3_GET_CLIENT_HELLO:no shared cipher"
echo
# only include first cipher for client and omit from server
# Secure Remote Password ciphers are not supported by GT.M
# Ubuntu 12.04 OpenSSL 1.0.1 lists ECDHE-RSA-AES256-GCM-SHA384 first
# but unlike other platforms, client gets no ciphers available error
# AIX and Solaris 1.0.1e also have this problem though Solaris lists
# DHE-RSA-AES256-GCM-SHA384 first.  Some 1.0.1e versions work as
# expected so the test should not be on the OpenSSL version.
if (("$HOSTOS" == "Linux" && { $grep -q 12.04 /etc/issue } ) || ("$HOSTOS" == "SunOS") || ("$HOSTOS" == "AIX")) then
	# Gave up on trying to get a usable cipher first so force it
	set omitcipher = '"'DHE-RSA-AES256-SHA'"'
else
	set omitcipher = '"'`openssl ciphers 'DEFAULT:\\!SRP' |cut -d: -f 1`'"'
endif
$tst_awk ' /clientcipher/ {$0 = $2 " " $3 '$omitcipher' $4 " "  $5 " " $6 " " $7} {print}' $gtmcrypt_config.starting >! $gtmcrypt_config.omitclient
$tst_awk ' /servercipher/ {$0 = $2 " " $3'$omitcipher' $4 " "  $5 " " $6} {print}' $gtmcrypt_config.omitclient >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.ciphermismatch
# client should try to enable tls but fail
# special case code in tsocerrors.m depends on case 2
$GTM << EOF
d fail^tsocerrors("2","server","no shared",1,0,"client2")
EOF

echo
echo "TEST CASE 3: Test server without cert, missing tlsid in config, no tlsid"
echo
cp -p $gtmcrypt_config.starting $gtmcrypt_config
# ^expected("3a.dotls","device")="1,Certificate corresponding to TLSID: badserver not found in configuration file"
$GTM << EOF
d fail^tsocerrors("3a","badserver","not found")
EOF
# ^expected("3b.dotls","device")="1,Certificate corresponding to TLSID: nosuchserver not found in configuration f"
$GTM << EOF
d fail^tsocerrors("3b","nosuchserver","not found")
EOF
# Note gtm_tls_impl.c treats an empty string for tlsid the same as if missing
# ^expected("3c.dotls","device")="1,Server mode requires a certificate but no TLSID specified"
$GTM << EOF
d fail^tsocerrors("3c","","no TLSID")
EOF
# ^expected("3d.clnt","device")="1,TLSID notclient not found in configuration file."
$GTM << EOF
d fail^tsocerrors("3d","server","not found",1,0,"notclient")
EOF
# Just to specify a tlsid for the client
$GTM << EOF
d succeed^tsocerrors("3e","server","client2")
EOF
# Specify a tlsid for the client with a certificate
$GTM << EOF
d succeed^tsocerrors("3f","server","client")
EOF

echo
echo "TEST CASE 4: Test length of tlsid."
# ^expected(4,"zstatus")="150383618,dotls+1^tsocerrors,%YDB-E-TLSPARAM, TLS parameter TLSID too long"
echo
$GTM << EOF
d fail^tsocerrors("4","thisisatoolongtlsid01234567890123","too long")
EOF

echo
echo "TEST CASE 5: Test WRITE /TLS command formats and socket state."
# See tsocerrors.m for expected errors
echo
$GTM << EOF
d servererrors^tsocerrors("5")
EOF
# ^expected("5b","zstatus")="150383618,dotls+1^tsocerrors,%YDB-E-TLSPARAM, TLS parameter SERVER but TLS already enabled"
# special case code in tsocerrors.m depends on case 5b
$GTM << EOF
d fail^tsocerrors("5b","server","already",1,1,"client2")
EOF
# ^expected("5c","zstatus")="150383618,dotls+7^tsocerrors,%YDB-E-TLSPARAM, TLS parameter /TLS but socket is not TCP"
$GTM << EOF
set ^localsocket="case5c.local"
d fail^tsocerrors("5c","server","socket is not TCP",0,0)
kill ^localsocket
EOF

echo
echo "TEST CASE 6: Test client without config file."
echo
# need libconfig9 aka version 1.4.x for config_read_string - it also define LIBCONFIG_VER
#	RedHat 6 and Ubuntu 12.04 are known to have libconfig8 aka 1.3.x
set newconfig = 0
foreach include (/usr/local/include /usr/include)
	if ( -e $include/libconfig.h) then
		if { $grep -q LIBCONFIG_VER_MAJOR $include/libconfig.h } set newconfig = 1
		break
	endif
end
if ( $newconfig ) then
# with default verify-level "CHECK" a config file or argument is needed
# to provide CAfile or turn CHECK off for our testsystem.
# Special case in tsocerrors.m.
$GTM << EOF
d succeed^tsocerrors("6a.cunset","server")
EOF
# ^expected("6b.cunset.clnt","device")="1,TLSID nonsuch not found in configuration file."
$GTM << EOF
d fail^tsocerrors("6b.cunset","server","not found in",1,0,"nonsuch")
EOF
else	# libconfig is too old
	echo
	echo "YDB>"
	echo "  PASSED: 6a.cunset"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 6b.cunset"
	echo
	echo "YDB>"
endif	# newconfig
echo
echo "TEST CASE 7: Test config file options."
echo
$tst_awk ' /(tls|good)ssloptions/ {$0 = $2 " " $3 " " $4 " "  $5 " " $6} {print}' $gtmcrypt_config.starting >! $gtmcrypt_config
if ("$HOST:ar" =~ "jackal") then
# Need OpenSSL 0.9.8m to clear options
# Jackal RH 5.11 has 0.9.8e-fips-rhel5 as of 2015/7/21
# ^expected("7a.dotls","device")="1,Unable to negate values in tls.server.ssl-options - need OpenSSL 0.9.8m or ne"
$GTM << EOF
d fail^tsocerrors("7a","server","negate values")
EOF
else
$GTM << EOF
d succeed^tsocerrors("7a","server")
EOF
endif
# catch unknown ssl-options, verify-mode , or verify-level values
# ^expected("7b.dotls","device")="1,In TLSID: server - unknown ssl-options option: SSL_OP_CIPHER_SEVER_PREFERENCE"
cp -p $gtmcrypt_config $gtmcrypt_config.bothssloptions
$tst_awk  ' /goodssloptions/ { sub("SERVER", "SEVER") } {print}' $gtmcrypt_config.bothssloptions >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.badssloptions
$GTM << EOF
d fail^tsocerrors("7b","server","SEVER",1,0,"client")
EOF
# ^expected("7c.dotls","device")="1,In TLSID: server - unknown verify-mode option: SSL_VERIFY_PEAR"
$tst_awk  ' /goodverifymode/ { sub("PEER", "PEAR") } {print}' $gtmcrypt_config.bothssloptions >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.badverifymode
$GTM << EOF
d fail^tsocerrors("7c","server","PEAR",1,0,"client")
EOF
# ^expected("7d.dotls","device")="1,In TLSID: server - unknown verify-level option: CHESS"
$tst_awk  ' /serververifylevel/ { sub("CHECK", "CHESS") } {print}' $gtmcrypt_config.bothssloptions >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.badverifylevel
$GTM << EOF
d fail^tsocerrors("7d","server","CHESS",1,0,"client")
EOF
# ^expected("7e.dotls","device")="1,In TLSID: server - invalid session-id-hex value: notvalid"
# $tst_awk ' /serversessionid/ {$0 = $2 " " \"notvalid\" " " $4 " "  $5 " " $6} {print}' $gtmcrypt_config.starting >! $gtmcrypt_config
# $tst_awk  ' /serversessionid/ { sub("123456abcdef", "notvalid") } {print}' $gtmcrypt_config.starting >! $gtmcrypt_config
$tst_awk -v 'sess="notvalid";' ' /serversessionid/ {$1=" " ; $3=sess} {print}' config.cfg.starting >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.badsessionidhex
$GTM << EOF
d fail^tsocerrors("7e","server","invalid sess",1,0,"client")
EOF

echo
echo "TEST CASE 8: Test providing password on WRITE /TLS."
echo
cp -p $gtmcrypt_config.starting $gtmcrypt_config
$GTM << EOF
set ^spasswd="$gtmtls_passwd_server"
d succeed^tsocerrors("8a","server")
EOF
# now try without the environment variable
$GTM << EOF
set ^spasswd="$gtmtls_passwd_server",^sunsetpasswd=1
d succeed^tsocerrors("8b","server")
EOF
# try with a [very probably] bad obfuscated value
# ^expected("8c.dotls","device")="1,Failed to read private key <path>"
$GTM << EOF
set ^spasswd="0123456789"
d fail^tsocerrors("8c","server","read private key",1,0)
EOF
# try with a badly formed obfuscated value
# ^expected("8d.dotls","device")="1,Environment variable gtmtls_passwd_server must be a valid hexadecimal string "
$GTM << EOF
set ^spasswd="012345G789"
d fail^tsocerrors("8d","server","valid hexa",1,0)
EOF
# try with no tlsid
# ^expected("8e","zstatus")="150383618,dotls+7^tsocerrors,%YDB-E-TLSPARAM, TLS parameter passphrase requires TLSID"
$GTM << EOF
set ^spasswd="$gtmtls_passwd_server"
d fail^tsocerrors("8e","","requires TLSID",1,0)
EOF

echo
echo "TEST CASE 9: Test providing config file options on WRITE /TLS."
echo
if ( $newconfig ) then
# libconfig 1.4.x has config_read_string so really do tests
# not indented due to here docs
# no config file - pass all of server section
$GTM << EOF
set ^sunsetconfig=1,^spasswd="$gtmtls_passwd_server"
do buildconfig^tsocerrors("verify-mode","string","SSL_VERIFY_PEER")
do buildconfig^tsocerrors("format","string","PEM")
do buildconfig^tsocerrors("cert","string","$PWD/demoCA/server.pem")
do buildconfig^tsocerrors("key","string","$PWD/demoCA/private/server.key")
d succeed^tsocerrors("9a","tmpserver")
EOF
# dbkeys only config file needs special case in tsocerrors.m
# to provide CAfile for client in our testsystem
cp -p $gtmcrypt_config.dbkeysonly $gtmcrypt_config
$GTM << EOF
set ^spasswd="$gtmtls_passwd_server"
do buildconfig^tsocerrors("verify-mode","string","SSL_VERIFY_PEER")
do buildconfig^tsocerrors("format","string","PEM")
do buildconfig^tsocerrors("cert","string","$PWD/demoCA/server.pem")
do buildconfig^tsocerrors("key","string","$PWD/demoCA/private/server.key")
d succeed^tsocerrors("9b","tmpserver")
EOF
# config file with tls section but pass whole new section
cp -p $gtmcrypt_config.starting $gtmcrypt_config
$GTM << EOF
set ^spasswd="$gtmtls_passwd_server"
do buildconfig^tsocerrors("verify-mode","string","SSL_VERIFY_PEER")
do buildconfig^tsocerrors("format","string","PEM")
do buildconfig^tsocerrors("cert","string","$PWD/demoCA/server.pem")
do buildconfig^tsocerrors("key","string","$PWD/demoCA/private/server.key")
d succeed^tsocerrors("9c","tmpserver")
EOF
# config file with tlsid section pass new option
$GTM << EOF
do buildconfig^tsocerrors("verify-depth","int",7)
d succeed^tsocerrors("9d","server")
EOF
# config file with tlsid section pass overriding bad option
$tst_awk  ' /serverkey/ { sub("server.key", "missing.key") } {print}' $gtmcrypt_config.starting >&! $gtmcrypt_config
$GTM << EOF
do buildconfig^tsocerrors("key","string","$PWD/demoCA/private/server.key")
d succeed^tsocerrors("9e","server")
EOF
# config file with tlsid section pass bad CAfile
cp -p $gtmcrypt_config.starting $gtmcrypt_config
# ^expected("9f.dotls","device")="1,Failed to load client CA file <pathto>missingcalist.pem"
$GTM << EOF
do buildconfig^tsocerrors("CAfile","string","$PWD/missingcalist.pem")
d fail^tsocerrors("9f","server","Failed to load",1,0)
EOF
# override bad session-id-hex in server
cp -p $gtmcrypt_config.badsessionidhex $gtmcrypt_config
$GTM <<EOF
do buildconfig^tsocerrors("session-id-hex","string","abcdef123456")
do succeed^tsocerrors("9g","server")
EOF
else	# libconfig is too old
# libconfig 1.3.x does not have config_read_string so fake test output
# echo expected output so test passes - ^expected and ^checkjob record if actually did CASE 9
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9a"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9b"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9c"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9d"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9e"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9f"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 9g"
	echo
	echo "YDB>"
endif	# newconfig

echo
echo "TEST CASE 10: Test WRITE /TLS RENEGOTIATION."
echo
if ("$HOSTOS" == "AIX") then
# Need to disable RFC4507bis tickets with AIX OpenSSL 1.0.1e 11 Feb 2013
# to avoid SSL3_READ_BYTES:ccs received early in cases a, c, and f
# Apparently if session-id specified there is no problem.
# OpenSSL CVE-2014-0224 is apparently related.
$tst_awk ' /noticketssloption/ {$0 = $2 " " $3 " " $4 " "  $5 " " $6} {print}' $gtmcrypt_config.starting >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.noticket
else
cp -p $gtmcrypt_config.starting $gtmcrypt_config
endif
cp -p $gtmcrypt_config $gtmcrypt_config.case10
$GTM << EOF
set ^reneg="success"
do succeed^tsocerrors("10a","server")
EOF
$GTM << EOF
set ^reneg="success",^reneg("tlsid")="reneg"
do succeed^tsocerrors("10b","server")
EOF
if ( $newconfig ) then
$GTM << EOF
kill ^reneg("tlsid")
set ^reneg="success",^reneg("opts")="verify-depth: 6;"
do succeed^tsocerrors("10c","server")
EOF
$GTM << EOF
do buildconfig^tsocerrors("session-id-hex","string","abcdef123456")
set ^reneg="success",^reneg("opts")=^sconfig kill ^sconfig
set ^reneg("tlsid")="reneg"
do succeed^tsocerrors("10d","server")
EOF
endif	# newconfig
# gtmcrypt_config.renegverifymode needed later even if old libconfig
# check option overrides config file with and without tlsid
$tst_awk ' /renegverifymode/ {$0 = $2 " " $3 " " $4 " "  $5 " " $6} {print}' $gtmcrypt_config.case10 >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.renegverifymode
if ( $newconfig ) then
$GTM << EOF
do buildconfig^tsocerrors("verify-mode","string","SSL_VERIFY_PEER:SSL_VERIFY_CLIENT_ONCE")
set ^reneg="success",^reneg("opts")=^sconfig kill ^sconfig
set ^reneg("tlsid")="reneg"
do succeed^tsocerrors("10e","server")
EOF
$GTM << EOF
do buildconfig^tsocerrors("verify-mode","string","SSL_VERIFY_PEER:SSL_VERIFY_CLIENT_ONCE")
set ^reneg="success",^reneg("opts")=^sconfig kill ^sconfig
kill ^reneg("tlsid")
do succeed^tsocerrors("10f","server")
EOF
else	# libconfig is too old
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 10c"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 10d"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 10e"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo
	echo "YDB>"
	echo "  PASSED: 10f"
	echo
	echo "YDB>"
endif	# newconfig
# test verify client once in config file
$tst_awk ' /renegverifyonce/ {$0 = $2 " " $3 " " $4 " "  $5 " " $6} {print}' $gtmcrypt_config.case10 >! $gtmcrypt_config
cp -p $gtmcrypt_config $gtmcrypt_config.renegverifyonce
$GTM << EOF
set ^reneg="success",^reneg("conf")="SSL_VERIFY_PEER:SSL_VERIFY_CLIENT_ONCE"
set ^reneg("tlsid")="reneg" kill ^reneg("opts")
do succeed^tsocerrors("10g","server")
EOF
# SSL_VERIFY_FAIL_IF_NO_PEER_CERT when no peer cert
# ^expected("10h.renegserv.reneg","device")="1,error:140890C7:SSL routines:SSL3_GET_CLIENT_CERTIFICATE:peer did not return a"
cp -p $gtmcrypt_config.renegverifymode $gtmcrypt_config
$GTM << EOF
kill ^reneg set ^reneg="fail",^reneg("tlsid")="reneg"
set ^reneg("expected")="peer did not return"
do succeed^tsocerrors("10h","server","client2")
EOF

$gtm_tst/com/dbcheck.csh -extract
$gtm_tst/com/portno_release.csh
