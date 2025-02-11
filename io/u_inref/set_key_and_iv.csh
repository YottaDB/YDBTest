#!/usr/local/bin/tcsh
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
# Copyright (c) 2025 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# In case of encryption, include one key for devices.
if ("ENCRYPT" == "$test_encryption") then
	setenv gtmcrypt_key	key
	setenv gtmcrypt_iv	`$gtm_dist/mumps -run %XCMD 'write $$^%RANDSTR(16,,"AN")'`
else
	setenv gtmcrypt_config	/dev/null
	setenv gtmcrypt_key	""
	setenv gtmcrypt_iv	""
endif
cat >> $gtmcrypt_config <<EOF
files : {
	key : "$PWD/mumps_dat_key";
};
EOF
