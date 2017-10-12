#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Various tests to verify that the plugin reports appropriate errors.

set CA="openssl ca"

set SH = "/bin/sh"
if ("$HOSTOS" == "SunOS") set SH = "/usr/xpg4/bin/sh"

# On certain platforms, ``openssl'' is found in /usr/local/ssl/bin. So, add that to the path as well.
setenv PATH ${PATH}:/usr/local/ssl/bin

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

# To avoid adding extra stuff onto the config file later, add a dummy crl and when it is time for TEST CASE 7, just update the
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

# Create the config file with a verify depth of 2. This should cause a failure as there are 3 certificates involved in the
# verification chain (rootca, intermediate-ca-1 and intermediate-ca-2).
setenv gtmcrypt_config `pwd`/config.cfg
cat << EOF >&! $gtmcrypt_config
tls: {
	verify-depth: 2;
	CAfile: "$PWD/calist.pem";
	crl: "$PWD/gtm.crl";
	dh512: "$gtm_tst/com/tls/dh512.pem";
	dh1024: "$gtm_tst/com/tls/dh1024.pem";

	INSTANCE1: {
		format: "PEM";
		cert: "$PWD/demoCA/client.pem";
		key: "$PWD/demoCA/private/client.key";
	};

	INSTANCE2: {
		format: "PEM";
		cert: "$PWD/demoCA/server.pem";
		key: "$PWD/demoCA/private/server.key";
	};
};

database: {
	keys: ( {
		dat: "mumps.dat";
		key: "mumps_dat_key";
	} );
};
EOF

$MULTISITE_REPLIC_PREPARE 2

setenv gtm_test_repl_skipsrcchkhlth
setenv gtm_test_repl_skiprcvrchkhlth
# Set plaintext fallback option so that the source/receiver server doesn't die and it makes the testing easy.
# Since the initial connection fails and a plaintext fallback connection happens, on some servers on rare occations
# it takes more than 60 seconds to establish connection. Start SRC and RCVR separately
# to skip the "are replication servers connected in 60 seconds" check that RF_START.csh does.
setenv gtm_test_plaintext_fallback

$MULTISITE_REPLIC_ENV

$gtm_tst/com/dbcreate.csh mumps 1

echo
echo "TEST CASE 1: Small value for verify-depth should issue an appropriate error."
echo

$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"

source $gtm_tst/$tst/u_inref/filter_TLSHANDSHAKE.csh $time_src $time_rcvr

$MSR STOP INST1 INST2

echo
echo "TEST CASE 2: Bad private key should issue an appropriate error."
echo

# First fix the config file so that we don't end up with the same error.
cp $gtmcrypt_config $gtmcrypt_config.bad1
sed 's/verify-depth: 2/verify-depth: 7/g' $gtmcrypt_config.bad1 >&! $gtmcrypt_config
# Mess up the private key by adding bad text in the middle of the client's private key.
cp $PWD/demoCA/private/client.key $PWD/demoCA/private/client.key.bak
set linecnt = `wc -l $PWD/demoCA/private/client.key | $tst_awk '{print $1}'`
@ idx = $linecnt / 2
$head -n $idx $PWD/demoCA/private/client.key.bak 	>&! $PWD/demoCA/private/client.key
echo "fOObAR" 						>>&! $PWD/demoCA/private/client.key
@ rem = $linecnt - $idx
$tail -n $rem $PWD/demoCA/private/client.key.bak	>>&! $PWD/demoCA/private/client.key

$MSR STARTSRC INST1 INST2 RP
get_msrtime
set src_logfile = SRC_${time_msr}.log
$MSR STARTRCV INST1 INST2

$MSR RUN INST1 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $src_logfile -message TLSCONVSOCK"
$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSCONVSOCK' 'GTM-I-TEXT'"
$gtm_tst/com/knownerror.csh $msr_execute_last_out "GTM-W-TLSCONVSOCK"

$MSR STOP INST1 INST2

echo
echo "TEST CASE 3: Test that specifying neither CAfile nor CApath leads to an error due to failure in certificate validation"
echo
# First fix the bad client private key so that we don't end up with the same error.
mv $PWD/demoCA/private/client.key ./client.key.bad
cp $PWD/demoCA/private/client.key.bak $PWD/demoCA/private/client.key
# Now erase the CAfile configuration parameter.
cp $gtmcrypt_config $gtmcrypt_config.good
sed 's/CAfile.*;//g' $gtmcrypt_config.good >&! $gtmcrypt_config
cp $gtmcrypt_config $gtmcrypt_config.bad2

$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"

source $gtm_tst/$tst/u_inref/filter_TLSHANDSHAKE.csh $time_src $time_rcvr

$MSR STOP INST1 INST2

echo
echo "TEST CASE 4: Test that specifying a bad password issues appropriate error"
echo
# First fix the absent CAfile attribute in the configuration file.
cp $gtmcrypt_config.good $gtmcrypt_config
# Now mess up the $gtmtls_passwd_INSTANCE1
set save_passwd = $gtmtls_passwd_INSTANCE1
setenv gtmtls_passwd_INSTANCE1 `echo "baDpaSSworD" | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f3 -d' '`
echo $gtmtls_passwd_INSTANCE1 >&! badpasswd.log
# Take a copy of the certificate and private key that the client would use to aid in debugging.
cp ./demoCA/private/client.key ./client.key.test4
cp ./demoCA/client.pem ./client.pem.test4
$MSR STARTSRC INST1 INST2 RP
get_msrtime
set src_logfile = SRC_${time_msr}.log
$MSR STARTRCV INST1 INST2
$MSR RUN INST1 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $src_logfile -message TLSCONVSOCK"
$MSR RUN INST1 "set msr_dont_trace; $msr_err_chk $src_logfile 'W-TLSCONVSOCK' 'GTM-I-TEXT'"
$gtm_tst/com/knownerror.csh $msr_execute_last_out "GTM-W-TLSCONVSOCK"

$MSR STOP INST1 INST2

echo
echo "TEST CASE 5: Test that expired certificates issues appropriate errors."
echo
# First fix the bad password in the environment.
setenv gtmtls_passwd_INSTANCE1 $save_passwd

# Now create an expired certificate.
set startdate=`date +%y%m%d%H%M%S`Z
sleep 1
set enddate=`date +%y%m%d%H%M%S`Z
sleep 1
set subj = "/C=US/ST=PA/L=Malvern/O=FISGlobal/OU=EXPIRED/CN=www.fisglobal.com/emailAddress=EXPIRED@fisglobal.com"
$SH $gtm_tst/com/gencert.sh CERT --config ./openssl.cnf --out expired.pem --startdate $startdate --enddate $enddate --keysize 1024 \
			--pass gtmrocks --subj "$subj" --signca intermediate-ca-2.pem --signpass gtmrocks	>&! expiredcert.log
if ($status) then
	echo "Failed to generate server certificate. See servercert.log. Exiting"
	exit -1
endif
# Now make the expired certificate and key pair as INSTANCE1's SSL/TLS attributes.
cp $gtmcrypt_config $gtmcrypt_config.good
$tst_awk -v 'cert="'$PWD/demoCA/expired.pem'";' -v 'keyin="'$PWD/demoCA/private/expired.key'";' \
	 'BEGIN {x=0} /INSTANCE1/ {x=1} /cert/ {if (x) {$NF=cert}} /key/ {if (x) {$NF=keyin; x=0}} {print}' \
	 $gtmcrypt_config.good >&! $gtmcrypt_config

$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"

source $gtm_tst/$tst/u_inref/filter_TLSHANDSHAKE.csh $time_src $time_rcvr

$MSR STOP INST1 INST2

echo
echo "TEST CASE 6: Test that specifying only one of dh* parameters issues an appropriate error."
echo
# First fix the config file containing the expired certificate.
cp $gtmcrypt_config $gtmcrypt_config.bad3
cp $gtmcrypt_config.good $gtmcrypt_config

# If we wipe of dh512 from the config file, that would cause both the replication servers to error out with TLSCONVSOCK. But,
# sometimes, if the timing is right, only one of them would fail and the other would just experience connection reset. To test
# this deterministically, let's trigger the error only on INSTANCE1 by having a different config file for INSTANCE1.
sed 's/dh512.*//' $gtmcrypt_config.good >&! $gtmcrypt_config
$MSR STARTSRC INST1 INST2 RP
$MSR STARTRCV INST1 INST2
get_msrtime
set rcv_logfile = RCVR_${time_msr}.log

$MSR RUN INST2 "set msr_dont_trace; $gtm_tst/com/wait_for_log.csh -log $rcv_logfile -message TLSCONVSOCK"
$MSR RUN INST2 "set msr_dont_trace; $msr_err_chk $rcv_logfile 'W-TLSCONVSOCK' 'GTM-I-TEXT'"
$gtm_tst/com/knownerror.csh $msr_execute_last_out "GTM-W-TLSCONVSOCK"

$MSR STOP INST1 INST2

echo
echo "TEST CASE 7: Test that revoked certificates issues appropriate errors."
echo

# Set some helper variables.
set cert = "./demoCA/intermediate-ca-2.pem"
set key = "./demoCA/private/intermediate-ca-2.key"

# First fix teh config file containing bad dh512 parameter.
mv $gtmcrypt_config $gtmcrypt_config.bad4
cp $gtmcrypt_config.good $gtmcrypt_config

# Now revoke the client certificate.
$CA -config ./openssl.cnf -revoke ./demoCA/client.pem -cert $cert -keyfile $key -passin pass:gtmrocks >&! revoke.log
if ($status) then
	echo "TEST-E-FAILED, Failed to revoke client certificate. Exiting.."
	exit -1
endif

# Move the old dummy CRL out of the way.
mv gtm.crl gtm.crl.bak
mv gtm-inter-2.crl gtm-inter-2.crl.bak
# Now generate the new CRL file
$CA -config ./openssl.cnf -gencrl -out gtm-inter-2.crl -cert $cert -keyfile $key -passin pass:gtmrocks >&! gencrl.log
if ($status) then
	echo "TEST-E-FAILED, Failed to generate certificate revocation list. Exiting.."
	exit -1
endif
cat gtm-inter-2.crl gtm-inter-1.crl gtm-rootca.crl >&! gtm.crl

$MSR STARTSRC INST1 INST2 RP
get_msrtime
set time_src = "$time_msr"
$MSR STARTRCV INST1 INST2
get_msrtime
set time_rcvr = "$time_msr"

source $gtm_tst/$tst/u_inref/filter_TLSHANDSHAKE.csh $time_src $time_rcvr

$MSR STOP INST1 INST2

$gtm_tst/com/dbcheck.csh -extract
