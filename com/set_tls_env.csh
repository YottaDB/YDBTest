#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2013-2015 Fidelity National Information 	#
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

if ("TRUE" == $gtm_test_tls) then
	# Set the environment variable corresponding to the configuration file (similarly to set_encrypt_env.csh). Invoking this
	# script alone does not ensure the existence of a configuration file with TLS settings. Either create_key_file.csh needs
	# to be invoked (for instance, via dbcreate.csh), in which case a configuration file with both DB- and TLS-specific
	# settings is constructed, or $gtm_tst/com/tls/gtmtls.cfg needs to be copied as gtmcrypt.cfg to the test's directory for GT.M
	# to be able to obtain TLS settings.
	setenv gtmcrypt_config gtmcrypt.cfg
	set cntr = 1
	set passwd = `echo ydbrocks | $gtm_dist/plugin/gtmcrypt/maskpass | cut -f3 -d ' '`
	while ($cntr <= 16)
		set inst = "INSTANCE$cntr"
		# Set the password for each INSTANCE's private key.
		setenv gtmtls_passwd_$inst $passwd
		@ cntr = $cntr + 1
	end
	# Set password for socket use
	setenv gtmtls_passwd_client $passwd
	setenv gtmtls_passwd_server $passwd
	if ((0 != $gtm_test_rhel9_plus) && (0 != $gtm_test_use_V6_DBs)) then
		# It is a RHEL 9 or higher system and "$gtm_test_tls" is TRUE. In that case, disable choosing V6 builds
		# for dbcreate.csh as they would encounter the following error since libgcrypt.so.11 needed by the older
		# build maskpass is not available.
		#	pro/plugin/gtmcrypt/maskpass: error while loading shared libraries:
		#	libgcrypt.so.11: cannot open shared object file: No such file or directory
		echo '# gtm_test_use_V6_DBs being set to disable, in set_tls_env.csh, due to gtm_test_rhel9_plus TRUE' >>&! settings.csh
		setenv gtm_test_use_V6_DBs 0
	endif
endif
