#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2009, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

if ("TRUE" == $gtm_test_tls) then
	# Set the password in case this script is run in a remote host.
	setenv gtmtls_passwd_INSTANCE2 `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f3 -d ' '`
	set INST2_tlsid_param = "-tlsid=INSTANCE2"
else
	set INST2_tlsid_param = ""
endif
$MUPIP replic -receiver -start -listen=${1} -log=rcvr.log -buff=$tst_buffsize $INST2_tlsid_param >& start_INST2.tmp
cat start_INST2.tmp
