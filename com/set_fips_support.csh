#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This script identifies if the current machine supports FIPS mode or not. It checks for both OpenSSL and libgcrypt.

# First, set OpenSSL FIPS support.
# Currently, on most platforms FIPS support is not enabled. Any platform where FIPS support is enabled, FIPS capable OpenSSL
# is installed on /opt/openssl-fips. So, look for it, and if present, assume FIPS mode is supported on that platform.
setenv openssl_fips "FALSE"
if (-d /opt/openssl-fips) then
	setenv openssl_fips "TRUE"
endif

# Now, set libgcrypt's FIPS support.
which libgcrypt-config >&! /dev/null
if (! $status) then
	set gcrypt_version = `libgcrypt-config --version`
	if ("" == "$gcrypt_version") then
		setenv gcrypt_fips "FALSE"
	else if (`expr $gcrypt_version "<=" "1.4.1"`) then
		setenv gcrypt_fips "FALSE"
	else
		# While versions greater than 1.4.1 should support FIPS, we've seen issues due to HMAC differences on RedHat
		# platforms. See <libgcrypt_selftest_failed> for more details.
		if (-f /etc/issue) then
			$grep -q "Red Hat" /etc/issue
			if (0 == $status) then
				setenv gcrypt_fips "FALSE"
			else
				setenv gcrypt_fips "TRUE"
			endif
		else
			setenv gcrypt_fips "TRUE"
		endif
	endif
else
	setenv gcrypt_fips "FALSE"
endif
