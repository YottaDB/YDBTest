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
	endif
	# On Arch Linux, GT.M V62001 binaries installed from Sourceforge issue SIG-11 when trying to create multi-region gld
	# files with a gtmdbglvl setting of 0x1F0. Therefore disable gtmdbglvl in that case.
	if (`expr "V63000A" \> "$1"`) then
		echo "# Overriding setting of gtmdbglvl by ydb_prior_ver_check.csh (prior_ver = $1)" >>&! settings.csh
		echo "unsetenv gtmdbglvl" >>&! settings.csh
		unsetenv gtmdbglvl
	endif
	if ($ydb_test_tls13_plus) then
		# This is a system having TLS V1.3 which is not supported by the TLS plugin in pre-r1.24 builds of YottaDB.
		# If the test framework randomly chosen TLS, the source and/or receiver server running the pre-r1.24 build
		# would assert fail (SIG-6) in gtm_tls_impl.c line 1667 "assert(FALSE && ssl_version)". Therefore, disable
		# TLS in that case. In case the build is a pure GT.M build, TLS V1.3 is not supported either so disable TLS
		# in that case too. For example V63004 is a pure GT.M build but V63004_R122 is a YottaDB build of R1.22
		# (which had GT.M GT.M V6.3-004 integrated into it).
		if (!($1 =~ "V*_R*")) then
			# This is a pure GT.M build because it does not have a _Rxxx suffix (e.g. _R122)
			set disabletls = 1
		else
			# Check if the YottaDB release i.e. xxx in Rxxx is less than 124.
			set ydbrel = `echo $1 | sed 's/.*_R//g'`
			if ($ydbrel < 124) then
				set disabletls = 1
			else
				set disabletls = 0
			endif
		endif
		if ($disabletls) then
			echo "# Overriding setting of gtm_test_tls by ydb_prior_ver_check.csh TLS V1.3(prior_ver = $1)" >>&! settings.csh
			echo "setenv gtm_test_tls FALSE" >>&! settings.csh
			setenv gtm_test_tls "FALSE"
		endif
	endif
endif
