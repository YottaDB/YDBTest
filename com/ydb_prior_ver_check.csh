#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# $1 - prior version to do checks against
#
if ($?ydb_environment_init) then
	# This is a YDB setup.
	#
	# Versions prior to V63000A have issues running in UTF-8 mode (due to icu
	# library naming conventions that changed). So disable UTF8 mode testing in case the older version is < V63000A.
	if (`expr "V63000A" \> "$1"`) then
		if ($?gtm_chset) then
			if ("UTF-8" == $gtm_chset) then
				echo "# Overriding setting of gtm_chset by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
				echo "setenv gtm_chset M" >>&! settings.csh
				$switch_chset M >>&! switch_chset_ydb.out
				rm -f rand.o >& /dev/null # usually created by random_ver.csh and could cause INVOBJFILE due to CHSET mismatch
			endif
		endif
	endif
	if ("arch" == $gtm_test_linux_distrib) then
		# On Arch Linux, versions <= V63000A have issues running with TLS (source server issues TLSDLLNOOPEN error
		# with detail "libgtmtls.so: undefined symbol: SSLv23_method"). So disable TLS in case a version <= V63000A
		# gets chosen on an Arch linux host
		if (`expr "V63000A" \>= "$1"`) then
			echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
			echo "setenv gtm_test_tls FALSE" >>&! settings.csh
			setenv gtm_test_tls "FALSE"
		endif
		# On Arch Linux, in Oct 2018, OpenSSL 1.1.1 became the currently installed version and that started supporting
		# TLS V1.3 which the TLS plugin in YottaDB does not support. YottaDB builds do not have an issue with this since
		# they have a CMakeLists.txt override that forces one to use OpenSSL 1.0 (instead of 1.1*). Pure GT.M builds
		# do not have those changes and so if the test randomly chosen TLS, the source and receiver server assert
		# fail (SIG-6) in gtm_tls_impl.c line 1667 "assert(FALSE && ssl_version)". Therefore, disable TLS on Arch Linux
		# if ever we randomly chose a pure GT.M build (which is identified by the version name being Vxxxx without the
		# trailing _Ryyyy suffix). For example V63004 is a pure GT.M build but V63004_R122 is a YottaDB build of
		# the YottaDB mainline which had GT.M V6.3-004 integrated into it.
		if (!($1 =~ "V*_R*")) then
			echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh TLS V1.3(prior_ver = $1)" >>&! settings.csh
			echo "setenv gtm_test_tls FALSE" >>&! settings.csh
			setenv gtm_test_tls "FALSE"
		endif
	endif
	# On Arch Linux, GT.M V62001 binaries installed from Sourceforge issue SIG-11 when trying to create multi-region gld
	# files with a gtmdbglvl setting of 0x1F0. Therefore disable gtmdbglvl in that case.
	if (`expr "V63000A" \> "$1"`) then
		echo "# Overriding setting of gtmdbglvl by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
		echo "unsetenv gtmdbglvl" >>&! settings.csh
		unsetenv gtmdbglvl
	endif
endif
