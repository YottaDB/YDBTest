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
set log=passive_INST2
if ("TRUE" == $gtm_test_tls) then
	set INST2_tlsid_param = "-tlsid=INSTANCE2"
	# Set the password in case this script is run in a remote host.
	setenv gtmtls_passwd_INSTANCE2 `echo gtmrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f3 -d ' '`
else
	set INST2_tlsid_param = ""
endif
$MUPIP replic -source -passive -start -instsecondary=${1} -propagateprimary -log=${log}.log $INST2_tlsid_param >& ${log}.tmp
cat ${log}.tmp
