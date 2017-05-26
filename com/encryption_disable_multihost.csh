#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Encryption needs to be disabled in certain conditions if database is shipped across instances
# This script is to check those conditions and disable encryption if necessary
# Usage : source $gtm_tst/com/encryption_disable_multihost.csh <remote-host> <version>

set remote_host = "$1"
set remote_ver = "$2"

# In case of multi-host tests that transfer databases, disable encryption if
#  a) gtm_crypt_plugin is not set or if it is pointing to libgtmcrypt.so (since it points to random algo in each build); or
#  b) the remote host does not support encryption.
if !($?gtm_crypt_plugin) then
	setenv test_encryption "NON_ENCRYPT"
else
	if ("libgtmcrypt$gt_ld_shl_suffix" == "$gtm_crypt_plugin") then
		setenv test_encryption "NON_ENCRYPT"
	else
		set is_encrypt_supported = `$rsh $remote_host "$gtm_tst/com/is_encrypt_support.csh $remote_ver $tst_image"`
		if ("TRUE" != "$is_encrypt_supported") setenv test_encryption "NON_ENCRYPT"
	endif
endif
if ("NON_ENCRYPT" == "$test_encryption") then
	echo "# test_encryption modified by encryption_disable_multihost.csh"	>>&! settings.csh
	echo "setenv test_encryption $test_encryption" 				>>&! settings.csh
endif
